<#
.SYNOPSIS
    Adds or updates the mssql MCP server entry in ~/.cursor/mcp.json.

.DESCRIPTION
    Writes a single switchable `mssql` entry using Python + pyodbc with Windows Integrated Auth.
    Preserves any other existing entries in the file.
    Run Setup-Foundation.ps1 first on a new machine.

.PARAMETER Server
    SQL Server address. Default: 192.168.100.65,9123 (staging)

.PARAMETER Database
    Initial database to connect to. Default: QASandbox8

.EXAMPLE
    .\Setup-Cursor.ps1
    .\Setup-Cursor.ps1 -Database QASandbox10
#>

param(
    [string]$Server   = "192.168.100.65,9123",
    [string]$Database = "QASandbox8"
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "=== Setup-Cursor: mssql MCP ===" -ForegroundColor Cyan
Write-Host "  DB : $Server / $Database"
Write-Host ""

$cursorMcp = Join-Path $env:USERPROFILE ".cursor\mcp.json"
$serverPy  = Join-Path $env:USERPROFILE "credentials\mcp-mssql\server.py"

if (-not (Test-Path $serverPy)) {
    Write-Error "server.py not found at $serverPy. Run Apply-Dotfiles.ps1 and Setup-Foundation.ps1 first."
    exit 1
}

$conn_str = "Driver={ODBC Driver 17 for SQL Server};Server=$Server;Database=$Database;Trusted_Connection=yes;Encrypt=yes;TrustServerCertificate=yes;"

$pythonScript = @"
import json, sys, pathlib

cursor_mcp = sys.argv[1]
server_py  = sys.argv[2]
conn_str   = sys.argv[3]
database   = sys.argv[4]

mssql_entry = {
    'type': 'stdio',
    'command': 'python',
    'args': [server_py],
    'env': {
        'MSSQL_CONNECTION_STRING': conn_str,
        'MSSQL_DATABASE': database,
    }
}

p = pathlib.Path(cursor_mcp)
p.parent.mkdir(parents=True, exist_ok=True)

if p.exists():
    with open(p, encoding='utf-8-sig') as f:
        data = json.load(f)
else:
    data = {}

data.setdefault('mcpServers', {})
data['mcpServers']['mssql'] = mssql_entry

with open(p, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2)

print(f'Updated: {cursor_mcp} -> mcpServers.mssql = {database}')
"@

python -c $pythonScript $cursorMcp $serverPy $conn_str $Database
if ($LASTEXITCODE -ne 0) {
    Write-Error "Python script failed."
    exit 1
}

Write-Host ""
Write-Host "[OK]  mssql entry added to ~/.cursor/mcp.json." -ForegroundColor Green
Write-Host "      Restart Cursor to connect." -ForegroundColor Yellow
Write-Host ""

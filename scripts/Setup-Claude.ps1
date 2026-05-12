<#
.SYNOPSIS
    Adds or updates the mssql MCP server entry in ~/.claude.json for a ByDesign project.

.DESCRIPTION
    Injects a single switchable `mssql` entry under projects.<ByDesignRepo>.mcpServers.
    Uses Python + pyodbc via Windows Integrated Auth (no passwords).
    Run Setup-Foundation.ps1 first on a new machine.

.PARAMETER ByDesignRepo
    Path to the ByDesign repo on this machine. Default: C:\Code\ByDesign.bd
    Must match the path key used by Claude Code (forward or back slashes, case-insensitive).

.PARAMETER Server
    SQL Server address. Default: 192.168.100.65,9123 (staging)

.PARAMETER Database
    Initial database to connect to. Default: QASandbox8

.EXAMPLE
    .\Setup-Claude.ps1
    .\Setup-Claude.ps1 -ByDesignRepo C:\Code\bdgit -Database QASandbox10
#>

param(
    [string]$ByDesignRepo = "C:\Code\ByDesign.bd",
    [string]$Server       = "192.168.100.65,9123",
    [string]$Database     = "QASandbox8"
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "=== Setup-Claude: mssql MCP ===" -ForegroundColor Cyan
Write-Host "  Repo : $ByDesignRepo"
Write-Host "  DB   : $Server / $Database"
Write-Host ""

$claudeJson  = Join-Path $env:USERPROFILE ".claude.json"
$serverPy    = Join-Path $env:USERPROFILE "credentials\mcp-mssql\server.py"

if (-not (Test-Path $claudeJson)) {
    Write-Error "~/.claude.json not found. Open Claude Code at least once to create it."
    exit 1
}
if (-not (Test-Path $serverPy)) {
    Write-Error "server.py not found at $serverPy. Run Apply-Dotfiles.ps1 and Setup-Foundation.ps1 first."
    exit 1
}

$pythonScript = @"
import json, sys, re, pathlib

claude_json = sys.argv[1]
repo_raw    = sys.argv[2]
server_addr = sys.argv[3]
database    = sys.argv[4]
server_py   = sys.argv[5]

conn_str = (
    f'Driver={{ODBC Driver 17 for SQL Server}};'
    f'Server={server_addr};'
    f'Database={database};'
    f'Trusted_Connection=yes;'
    f'Encrypt=yes;'
    f'TrustServerCertificate=yes;'
)

mssql_entry = {
    'type': 'stdio',
    'command': 'python',
    'args': [server_py],
    'env': {
        'MSSQL_CONNECTION_STRING': conn_str,
        'MSSQL_DATABASE': database,
    }
}

with open(claude_json, encoding='utf-8-sig') as f:
    data = json.load(f)

projects = data.setdefault('projects', {})

# Normalise repo path to forward slashes, lowercase, for key lookup
def norm(p):
    return p.replace('\\\\', '/').replace('\\\\\\\\', '/').lower()

repo_norm = norm(repo_raw)
matched_key = None
for key in projects:
    if norm(key) == repo_norm:
        matched_key = key
        break

if matched_key is None:
    # Create the project key (use forward-slash lowercase form)
    matched_key = repo_raw.replace('\\\\', '/').replace('\\\\\\\\', '/')
    projects[matched_key] = {}

proj = projects[matched_key]
proj.setdefault('mcpServers', {})
proj['mcpServers']['mssql'] = mssql_entry

with open(claude_json, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2)

print(f'Updated: {matched_key} -> mcpServers.mssql = {database}')
"@

python -c $pythonScript $claudeJson $ByDesignRepo $Server $Database $serverPy
if ($LASTEXITCODE -ne 0) {
    Write-Error "Python script failed."
    exit 1
}

Write-Host ""
Write-Host "[OK]  mssql entry added to ~/.claude.json." -ForegroundColor Green
Write-Host "      Reload VS Code window (Ctrl+Shift+P -> Developer: Reload Window) to connect." -ForegroundColor Yellow
Write-Host ""

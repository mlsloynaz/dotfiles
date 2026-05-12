<#
.SYNOPSIS
    Installs Python packages required for the SQL Server MCP and verifies ODBC Driver 17.

.DESCRIPTION
    Run this once on a new machine before Setup-Claude.ps1 or Setup-Cursor.ps1.
    Installs: mcp, pyodbc
    Verifies: ODBC Driver 17 for SQL Server (must be installed separately if missing)

.EXAMPLE
    .\Setup-Foundation.ps1
#>

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "=== Setup-Foundation: SQL MCP prerequisites ===" -ForegroundColor Cyan
Write-Host ""

# --- Python check ---
try {
    $pyVersion = python --version 2>$null
    Write-Host "[OK]  Python: $pyVersion" -ForegroundColor Green
} catch {
    Write-Error "Python not found. Install from https://python.org/downloads (check 'Add Python to PATH')."
    exit 1
}

# --- pip install ---
Write-Host ""
Write-Host "Installing Python packages (mcp, pyodbc)..." -ForegroundColor Cyan
pip install mcp pyodbc
if ($LASTEXITCODE -ne 0) {
    Write-Error "pip install failed."
    exit 1
}
Write-Host "[OK]  mcp and pyodbc installed." -ForegroundColor Green

# --- ODBC Driver 17 check ---
Write-Host ""
$drv = Get-OdbcDriver -Name "ODBC Driver 17 for SQL Server" -ErrorAction SilentlyContinue
if ($drv) {
    Write-Host "[OK]  ODBC Driver 17 for SQL Server is installed." -ForegroundColor Green
} else {
    Write-Host "[!!]  ODBC Driver 17 for SQL Server NOT found." -ForegroundColor Red
    Write-Host "      Download msodbcsql.msi from:" -ForegroundColor Yellow
    Write-Host "      https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server" -ForegroundColor Yellow
    exit 1
}

# --- server.py check ---
Write-Host ""
$serverPy = Join-Path $env:USERPROFILE "credentials\mcp-mssql\server.py"
if (Test-Path $serverPy) {
    Write-Host "[OK]  server.py found at: $serverPy" -ForegroundColor Green
} else {
    Write-Host "[!!]  server.py not found at: $serverPy" -ForegroundColor Red
    Write-Host "      Run Apply-Dotfiles.ps1 first to deploy credentials\ from dotfiles." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Foundation ready. Run Setup-Claude.ps1 and/or Setup-Cursor.ps1 next." -ForegroundColor Green
Write-Host ""

<#
.SYNOPSIS
    Checks that all required tools are installed before applying dotfiles.

.DESCRIPTION
    Runs silently against each prerequisite and prints a pass/fail summary.
    Does NOT install anything. Run this before Apply-Dotfiles.ps1 on a new machine.

.EXAMPLE
    .\Check-Requirements.ps1
#>

$script:pass = [System.Collections.Generic.List[string]]::new()
$script:fail = [System.Collections.Generic.List[string]]::new()
$script:warn = [System.Collections.Generic.List[string]]::new()

function Check {
    param(
        [string]$Label,
        [scriptblock]$Test,
        [string]$FixHint,
        [switch]$Optional
    )
    try {
        $result = & $Test 2>$null
        if ($result) {
            $script:pass.Add("  [OK]  $Label  ($result)")
        } else {
            throw "empty result"
        }
    } catch {
        if ($Optional) {
            $script:warn.Add("  [--]  $Label (optional)  ->  $FixHint")
        } else {
            $script:fail.Add("  [!!]  $Label  ->  $FixHint")
        }
    }
}

Write-Host ""
Write-Host "Checking prerequisites..." -ForegroundColor Cyan
Write-Host ""

# --- Core CLI tools ---
Check "Git" {
    $v = git --version 2>$null
    if ($v) { $v -replace 'git version ','' } else { throw }
} "https://git-scm.com/download/win"

Check "Git LFS" {
    $v = git lfs version 2>$null
    if ($v) { ($v -replace 'git-lfs/','' -replace ' .*','').Trim() } else { throw }
} "Run: git lfs install  (after Git is installed)"

Check "GitHub CLI (gh)" {
    $v = gh --version 2>$null | Select-Object -First 1
    if ($v) { ($v -replace 'gh version ','' -replace ' .*','').Trim() } else { throw }
} "https://cli.github.com"

Check "Node.js" {
    $v = node --version 2>$null
    if ($v) { $v -replace 'v','' } else { throw }
} "https://nodejs.org  (install LTS)"

Check "npm" {
    $v = npm --version 2>$null
    if ($v) { $v } else { throw }
} "Reinstall Node.js from https://nodejs.org"

Check "Python 3" {
    $v = python --version 2>$null
    if ($v) { $v -replace 'Python ','' } else { throw }
} "https://python.org/downloads  (check 'Add Python to PATH' during install)"

# --- Editors ---
Check "VSCode" {
    $v = code --version 2>$null | Select-Object -First 1
    if ($v) { $v } else { throw }
} "https://code.visualstudio.com"

Check "Cursor AI" {
    $exe = "$env:LOCALAPPDATA\Programs\cursor\Cursor.exe"
    if (Test-Path $exe) { "found" } else { throw }
} "https://cursor.com"

# --- AI tooling ---
Check "Claude Code CLI" {
    $v = claude --version 2>$null | Select-Object -First 1
    if ($v) { $v } else { throw }
} "npm install -g @anthropic-ai/claude-code"

Check "Angular CLI 14" {
    $lines = ng version 2>$null
    $line  = $lines | Select-String "Angular CLI:" | Select-Object -First 1
    if ($line -and ($line -match '14\.\d+')) {
        $line.ToString().Trim()
    } else {
        $current = if ($line) { $line.ToString().Trim() } else { "not found" }
        throw "current: $current"
    }
} "npm install -g @angular/cli@14"

# --- SQL tooling ---
Check "ODBC Driver 17 for SQL Server" {
    $drv = Get-OdbcDriver -Name "ODBC Driver 17 for SQL Server" -ErrorAction SilentlyContinue
    if ($drv) { "installed" } else { throw }
} "Download 'msodbcsql.msi' from Microsoft (search: ODBC Driver 17 for SQL Server download)"

# --- Credentials ---
Check "credentials\msp-sql-credentials.json" {
    $p = "$env:USERPROFILE\credentials\msp-sql-credentials.json"
    if (Test-Path $p) { "found" } else { throw }
} "Run Apply-Dotfiles.ps1 first, then edit the file with staging server credentials"

# --- Optional ---
Check "Windows Terminal" {
    $wt = Get-Command wt -ErrorAction SilentlyContinue
    if ($wt) { $wt.Source } else { throw }
} "Microsoft Store -> search 'Windows Terminal'" -Optional

# --- Print summary ---
Write-Host "Results" -ForegroundColor Cyan
Write-Host ("-" * 60)

foreach ($line in $script:pass) { Write-Host $line -ForegroundColor Green }
foreach ($line in $script:warn) { Write-Host $line -ForegroundColor DarkYellow }
foreach ($line in $script:fail) { Write-Host $line -ForegroundColor Red }

Write-Host ("-" * 60)

if ($script:fail.Count -eq 0) {
    Write-Host "All required tools present ($($script:pass.Count) OK, $($script:warn.Count) optional skipped). Ready to run Apply-Dotfiles.ps1." -ForegroundColor Green
} else {
    Write-Host "$($script:fail.Count) requirement(s) missing. Install them before running Apply-Dotfiles.ps1." -ForegroundColor Red
}
Write-Host ""

<#
.SYNOPSIS
    Applies git dotfiles and guides through GitHub authentication on a new machine.

.DESCRIPTION
    1. Applies git config files from dotfiles (gitconfig, identity files, aliases, gitignore_global)
    2. Reminds you to fill in identity placeholders if not already done
    3. Runs `gh auth login` for GitHub authentication

.EXAMPLE
    .\Setup-Git.ps1
#>

$ErrorActionPreference = 'Stop'
$dotfiles = Join-Path $env:USERPROFILE "dotfiles"

Write-Host ""
Write-Host "=== Setup-Git ===" -ForegroundColor Cyan
Write-Host ""

# --- Check git ---
try {
    $v = git --version 2>$null
    Write-Host "[OK]  Git: $v" -ForegroundColor Green
} catch {
    Write-Error "Git not found. Install from https://git-scm.com/download/win"
    exit 1
}

# --- Check gh ---
try {
    $v = (gh --version 2>$null | Select-Object -First 1) -replace 'gh version ','' -replace ' .*',''
    Write-Host "[OK]  GitHub CLI: $v" -ForegroundColor Green
} catch {
    Write-Error "GitHub CLI not found. Install from https://cli.github.com"
    exit 1
}

# --- Apply git dotfiles ---
Write-Host ""
Write-Host "Applying git dotfiles..." -ForegroundColor Cyan

$pairs = @(
    @{ Src = "git\.gitconfig";          Dst = ".gitconfig" }
    @{ Src = "git\.gitconfig-personal"; Dst = ".gitconfig-personal" }
    @{ Src = "git\.gitconfig-work";     Dst = ".gitconfig-work" }
    @{ Src = "git\.gitconfig.aliases";  Dst = ".gitconfig-aliases" }
    @{ Src = "git\.gitignore_global";   Dst = ".gitignore_global" }
)
foreach ($p in $pairs) {
    $src = Join-Path $dotfiles $p.Src
    $dst = Join-Path $env:USERPROFILE $p.Dst
    if (-not (Test-Path $src)) {
        Write-Warning "Not found in dotfiles: $($p.Src) — skipped."
        continue
    }
    Copy-Item -LiteralPath $src -Destination $dst -Force
    Write-Host "  Copied: $($p.Src)" -ForegroundColor Green
}

# --- Identity placeholder check ---
Write-Host ""
$personal = Join-Path $env:USERPROFILE ".gitconfig-personal"
$work     = Join-Path $env:USERPROFILE ".gitconfig-work"
$needsEdit = $false
foreach ($f in @($personal, $work)) {
    if (Test-Path $f) {
        $content = Get-Content $f -Raw
        if ($content -match 'Your Name|your-personal-email|your-work-email') {
            Write-Host "[!!]  Placeholders found in: $f" -ForegroundColor Yellow
            Write-Host "      Edit the file and replace: Your Name, email address" -ForegroundColor Yellow
            $needsEdit = $true
        }
    }
}
if (-not $needsEdit) {
    Write-Host "[OK]  Git identity files look filled in." -ForegroundColor Green
}

# --- GitHub auth ---
Write-Host ""
Write-Host "Checking GitHub authentication..." -ForegroundColor Cyan
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK]  Already authenticated with GitHub." -ForegroundColor Green
} else {
    Write-Host "Running gh auth login..." -ForegroundColor Yellow
    gh auth login
}

# --- git lfs ---
Write-Host ""
try {
    git lfs install 2>$null | Out-Null
    Write-Host "[OK]  Git LFS initialized." -ForegroundColor Green
} catch {
    Write-Warning "Git LFS not found — install it if you work with large files."
}

Write-Host ""
Write-Host "Git setup complete." -ForegroundColor Green
Write-Host ""

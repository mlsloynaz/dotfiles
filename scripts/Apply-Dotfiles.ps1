<#
.SYNOPSIS
    Applies dotfiles: either creates symlinks (requires Administrator) or copies files to target locations.

.DESCRIPTION
    - Symlinks: Replaces target config files with symbolic links to this repo. Requires Administrator for file symlinks.
    - Copy: Copies files from dotfiles to the normal config locations. Use when you cannot run as Administrator.
    The .cursor\skills junction is created in both modes (no admin required for junction).

.PARAMETER Mode
    Symlinks = create symlinks (run as Administrator)
    Copy    = copy files from dotfiles to target paths (no admin needed)

.EXAMPLE
    .\Apply-Dotfiles.ps1 -Mode Copy
.EXAMPLE
    .\Apply-Dotfiles.ps1 -Mode Symlinks
#>

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Symlinks', 'Copy')]
    [string] $Mode = 'Copy'
)

$ErrorActionPreference = 'Stop'
# Dotfiles repo is assumed to be inside the user folder
$dotfiles = Join-Path $env:USERPROFILE "dotfiles"
$cursorUser = Join-Path $env:APPDATA "Cursor\User"
$cursorDir = Join-Path $env:USERPROFILE ".cursor"

function Ensure-ParentPath {
    param([string]$Path)
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

function New-SkillsJunction {
    $linkPath = Join-Path $cursorDir "skills"
    $targetPath = Join-Path $dotfiles "cursor\skills"
    if (-not (Test-Path -LiteralPath $targetPath)) {
        Write-Warning "Dotfiles skills folder not found: $targetPath. Skipping skills junction."
        return
    }
    if (Test-Path -LiteralPath $linkPath) {
        $item = Get-Item -LiteralPath $linkPath
        if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            Write-Host "Junction .cursor\skills already exists."
            return
        }
        Write-Warning ".cursor\skills exists and is not a link. Remove it manually if you want to replace with junction."
        return
    }
    cmd /c mklink /J "`"$linkPath`"" "`"$targetPath`""
    Write-Host "Junction created: .cursor\skills -> dotfiles\cursor\skills"
}

# --- Skills junction (both modes, no admin required) ---
Ensure-ParentPath -Path $cursorDir
New-SkillsJunction

if ($Mode -eq 'Copy') {
    # Copy files from dotfiles to target locations
    $pairs = @(
        @{ Src = "cursor\settings.json";     Dst = (Join-Path $cursorUser "settings.json") }
        @{ Src = "cursor\keybindings.json";  Dst = (Join-Path $cursorUser "keybindings.json") }
        @{ Src = "cursor\mcp.json";          Dst = (Join-Path $cursorDir "mcp.json") }
        @{ Src = "git\.gitconfig";           Dst = (Join-Path $env:USERPROFILE ".gitconfig") }
        @{ Src = "git\.gitignore_global";    Dst = (Join-Path $env:USERPROFILE ".gitignore_global") }
    )
    foreach ($p in $pairs) {
        $src = Join-Path $dotfiles $p.Src
        if (-not (Test-Path -LiteralPath $src)) {
            Write-Warning "Source not found: $src"
            continue
        }
        Ensure-ParentPath -Path $p.Dst
        Copy-Item -LiteralPath $src -Destination $p.Dst -Force
        Write-Host "Copied: $($p.Src) -> $($p.Dst)"
    }
    Write-Host "Copy mode done."
    exit 0
}

# --- Symlinks mode (requires Administrator) ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Symlinks mode requires Administrator. Right-click PowerShell -> Run as administrator, or use -Mode Copy."
    exit 1
}

$fileLinks = @(
    @{ TargetPath = (Join-Path $cursorUser "settings.json");     LinkTarget = (Join-Path $dotfiles "cursor\settings.json") }
    @{ TargetPath = (Join-Path $cursorUser "keybindings.json");  LinkTarget = (Join-Path $dotfiles "cursor\keybindings.json") }
    @{ TargetPath = (Join-Path $cursorDir "mcp.json");           LinkTarget = (Join-Path $dotfiles "cursor\mcp.json") }
    @{ TargetPath = (Join-Path $env:USERPROFILE ".gitconfig");    LinkTarget = (Join-Path $dotfiles "git\.gitconfig") }
    @{ TargetPath = (Join-Path $env:USERPROFILE ".gitignore_global"); LinkTarget = (Join-Path $dotfiles "git\.gitignore_global") }
)

foreach ($item in $fileLinks) {
    if (-not (Test-Path -LiteralPath $item.LinkTarget)) {
        Write-Warning "Dotfiles source not found: $($item.LinkTarget)"
        continue
    }
    if (Test-Path -LiteralPath $item.TargetPath) {
        $current = Get-Item -LiteralPath $item.TargetPath
        if ($current.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            Remove-Item -LiteralPath $item.TargetPath -Force
        } else {
            Remove-Item -LiteralPath $item.TargetPath -Force
        }
    }
    Ensure-ParentPath -Path $item.TargetPath
    New-Item -ItemType SymbolicLink -Path $item.TargetPath -Target $item.LinkTarget -Force | Out-Null
    Write-Host "Symlink: $($item.TargetPath) -> $($item.LinkTarget)"
}

Write-Host "Symlinks mode done."

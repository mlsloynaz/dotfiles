<#
.SYNOPSIS
    Applies dotfiles: either creates symlinks (requires Administrator) or copies files to target locations.

.DESCRIPTION
    - Symlinks: Replaces target config files with symbolic links to this repo. Requires Administrator for file symlinks.
    - Copy: Copies files from dotfiles to the normal config locations. Use when you cannot run as Administrator.
    The .cursor\skills junction is created in both modes (no admin required for junction).
    User-level Cursor rules (.mdc) are synced from dotfiles\cursor\rules to %USERPROFILE%\.cursor\rules.
    Claude Code user config is synced from dotfiles\claude to %USERPROFILE%\.claude (policy-limits, commands junction, optional settings.json / mcp.json).

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
$claudeHome = Join-Path $env:USERPROFILE ".claude"
$claudeSrc = Join-Path $dotfiles "claude"

function Ensure-ParentPath {
    param([string]$Path)
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

function Sync-CursorRules {
    param([string]$Mode)
    $rulesSrc = Join-Path $dotfiles "cursor\rules"
    $rulesDst = Join-Path $cursorDir "rules"
    if (-not (Test-Path -LiteralPath $rulesSrc)) {
        Write-Warning "Dotfiles cursor rules folder not found: $rulesSrc. Skipping rules sync."
        return
    }
    if ($Mode -eq 'Copy') {
        Ensure-ParentPath -Path $rulesDst
        Copy-Item -Path (Join-Path $rulesSrc '*') -Destination $rulesDst -Recurse -Force
        Write-Host "Copied cursor rules: $rulesSrc -> $rulesDst"
        return
    }
    if (Test-Path -LiteralPath $rulesDst) {
        $item = Get-Item -LiteralPath $rulesDst -Force
        if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            Remove-Item -LiteralPath $rulesDst -Force
        } else {
            Remove-Item -LiteralPath $rulesDst -Recurse -Force
        }
    }
    Ensure-ParentPath -Path $rulesDst
    New-Item -ItemType SymbolicLink -Path $rulesDst -Target $rulesSrc -Force | Out-Null
    Write-Host "Symlink: $rulesDst -> $rulesSrc"
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

function New-DirJunction {
    param([string]$LinkPath, [string]$TargetPath, [string]$Label)
    if (-not (Test-Path -LiteralPath $TargetPath)) {
        Write-Warning "Dotfiles source not found: $TargetPath. Skipping $Label."
        return
    }
    if (Test-Path -LiteralPath $LinkPath) {
        $item = Get-Item -LiteralPath $LinkPath -Force
        if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            Write-Host "Junction $Label already exists."
            return
        }
        Write-Warning "$LinkPath exists and is not a junction. Remove it manually to replace with junction."
        return
    }
    Ensure-ParentPath -Path $LinkPath
    cmd /c mklink /J "`"$LinkPath`"" "`"$TargetPath`""
    Write-Host "Junction created: $Label"
}

function Sync-ClaudeCopy {
    if (-not (Test-Path -LiteralPath $claudeSrc)) {
        Write-Warning "Dotfiles claude folder not found: $claudeSrc. Skipping Claude sync."
        return
    }
    Ensure-ParentPath -Path $claudeHome
    $policySrc = Join-Path $claudeSrc "policy-limits.json"
    if (Test-Path -LiteralPath $policySrc) {
        Copy-Item -LiteralPath $policySrc -Destination (Join-Path $claudeHome "policy-limits.json") -Force
        Write-Host "Copied: claude\policy-limits.json -> $claudeHome\policy-limits.json"
    }
    $commandsSrc = Join-Path $claudeSrc "commands"
    if (Test-Path -LiteralPath $commandsSrc) {
        $commandsDst = Join-Path $claudeHome "commands"
        Ensure-ParentPath -Path $commandsDst
        Copy-Item -Path (Join-Path $commandsSrc '*') -Destination $commandsDst -Recurse -Force
        Write-Host "Copied: claude\commands\ -> $commandsDst"
    }
    foreach ($name in @('settings.json', 'mcp.json')) {
        $src = Join-Path $claudeSrc $name
        if (Test-Path -LiteralPath $src) {
            Copy-Item -LiteralPath $src -Destination (Join-Path $claudeHome $name) -Force
            Write-Host "Copied: claude\$name -> $claudeHome\$name"
        } else {
            Write-Host "Skipped (not in dotfiles): claude\$name — copy from settings.example.json / mcp.example.json if needed."
        }
    }
}

function Sync-ClaudeSymlinks {
    if (-not (Test-Path -LiteralPath $claudeSrc)) {
        Write-Warning "Dotfiles claude folder not found: $claudeSrc. Skipping Claude sync."
        return
    }
    Ensure-ParentPath -Path $claudeHome
    $policySrc = Join-Path $claudeSrc "policy-limits.json"
    if (Test-Path -LiteralPath $policySrc) {
        $policyDst = Join-Path $claudeHome "policy-limits.json"
        if (Test-Path -LiteralPath $policyDst) {
            $cur = Get-Item -LiteralPath $policyDst -Force
            if ($cur.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                Remove-Item -LiteralPath $policyDst -Force
            } else {
                Remove-Item -LiteralPath $policyDst -Force
            }
        }
        New-Item -ItemType SymbolicLink -Path $policyDst -Target $policySrc -Force | Out-Null
        Write-Host "Symlink: $policyDst -> $policySrc"
    }
    foreach ($name in @('settings.json', 'mcp.json')) {
        $src = Join-Path $claudeSrc $name
        if (-not (Test-Path -LiteralPath $src)) { continue }
        $dst = Join-Path $claudeHome $name
        if (Test-Path -LiteralPath $dst) {
            $cur = Get-Item -LiteralPath $dst -Force
            if ($cur.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                Remove-Item -LiteralPath $dst -Force
            } else {
                Remove-Item -LiteralPath $dst -Force
            }
        }
        New-Item -ItemType SymbolicLink -Path $dst -Target $src -Force | Out-Null
        Write-Host "Symlink: $dst -> $src"
    }
    New-DirJunction -LinkPath (Join-Path $claudeHome "commands") -TargetPath (Join-Path $claudeSrc "commands") -Label "claude commands"
}

# --- Skills junction (both modes, no admin required) ---
Ensure-ParentPath -Path $cursorDir
New-SkillsJunction

if ($Mode -eq 'Copy') {
    Sync-CursorRules -Mode Copy
    Sync-ClaudeCopy
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
    # Copy directories
    $dirs = @(
        @{ Src = "bd-repo.cursor"; Dst = (Join-Path $env:USERPROFILE "bd-repo.cursor") }
        @{ Src = "credentials";    Dst = (Join-Path $env:USERPROFILE "credentials") }
    )
    foreach ($d in $dirs) {
        $src = Join-Path $dotfiles $d.Src
        if (-not (Test-Path -LiteralPath $src)) {
            Write-Warning "Source not found: $src"
            continue
        }
        Copy-Item -Path $src -Destination $d.Dst -Recurse -Force
        Write-Host "Copied dir: $($d.Src) -> $($d.Dst)"
    }
    Write-Host "Copy mode done."
    exit 0
}

# --- Symlinks mode (requires Administrator) ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Symlinks mode requires Administrator. Right-click PowerShell -> Run as administrator, or use -Mode Copy."
    exit 1
}

Sync-CursorRules -Mode Symlinks
Sync-ClaudeSymlinks

# Directory junctions (no admin required)
New-DirJunction -LinkPath (Join-Path $env:USERPROFILE "bd-repo.cursor") -TargetPath (Join-Path $dotfiles "bd-repo.cursor") -Label "bd-repo.cursor"
New-DirJunction -LinkPath (Join-Path $env:USERPROFILE "credentials")    -TargetPath (Join-Path $dotfiles "credentials")    -Label "credentials"

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

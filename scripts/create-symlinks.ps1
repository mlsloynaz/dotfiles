# Run this script as Administrator to create symlinks from your config locations to this dotfiles repo.
# Usage: Right-click PowerShell -> Run as administrator, then:
#   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
#   & "$env:USERPROFILE\dotfiles\scripts\create-symlinks.ps1"

$ErrorActionPreference = 'Stop'
# Dotfiles repo is assumed to be inside the user folder
$dotfiles = Join-Path $env:USERPROFILE "dotfiles"
$cursorUser = Join-Path $env:APPDATA "Cursor\User"

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script requires Administrator. Right-click PowerShell -> Run as administrator."
    exit 1
}

# Cursor
$cursorSettings = Join-Path $cursorUser "settings.json"
$cursorKeybindings = Join-Path $cursorUser "keybindings.json"
Remove-Item $cursorSettings -Force -ErrorAction SilentlyContinue
Remove-Item $cursorKeybindings -Force -ErrorAction SilentlyContinue
New-Item -ItemType SymbolicLink -Path $cursorSettings -Target (Join-Path $dotfiles "cursor\settings.json") -Force
New-Item -ItemType SymbolicLink -Path $cursorKeybindings -Target (Join-Path $dotfiles "cursor\keybindings.json") -Force
Write-Host "Cursor symlinks created."

# Git
$gitconfigAliases = Join-Path $env:USERPROFILE ".gitconfig-aliases"
$gitconfig = Join-Path $env:USERPROFILE ".gitconfig"
$gitignoreGlobal = Join-Path $env:USERPROFILE ".gitignore_global"
Remove-Item $gitconfigAliases -Force -ErrorAction SilentlyContinue
Remove-Item $gitconfig -Force -ErrorAction SilentlyContinue
Remove-Item $gitignoreGlobal -Force -ErrorAction SilentlyContinue
New-Item -ItemType SymbolicLink -Path $gitconfigAliases -Target (Join-Path $dotfiles "git\.gitconfig.aliases") -Force
New-Item -ItemType SymbolicLink -Path $gitconfig -Target (Join-Path $dotfiles "git\.gitconfig") -Force
New-Item -ItemType SymbolicLink -Path $gitignoreGlobal -Target (Join-Path $dotfiles "git\.gitignore_global") -Force
Write-Host "Git symlinks created."
Write-Host "Done."
exit 0

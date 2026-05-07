param(
    [string]$DotfilesRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [string]$ByDesignRepo = 'C:\Code\ByDesign.bd',
    [switch]$SkipByDesignProjectRules
)

$ErrorActionPreference = 'Stop'

function Copy-FileIfExists {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (-not (Test-Path $Source)) {
        Write-Host "Skip missing file: $Source"
        return
    }

    $destinationFolder = Split-Path $Destination -Parent
    New-Item -ItemType Directory -Force $destinationFolder | Out-Null

    if (Test-Path $Destination) {
        $sourceHash = (Get-FileHash $Source).Hash
        $destinationHash = (Get-FileHash $Destination).Hash

        if ($sourceHash -eq $destinationHash) {
            Write-Host "Already current: $Destination"
            return
        }
    }

    try {
        Copy-Item $Source $Destination -Force
        Write-Host "Installed file: $Source -> $Destination"
    }
    catch {
        Write-Warning "Could not install file: $Source. $($_.Exception.Message)"
    }
}

function Copy-FolderIfExists {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (-not (Test-Path $Source)) {
        Write-Host "Skip missing folder: $Source"
        return
    }

    $sourceRoot = (Resolve-Path $Source).Path
    New-Item -ItemType Directory -Force $Destination | Out-Null
    Get-ChildItem $sourceRoot -Recurse -Force | ForEach-Object {
        $relativePath = $_.FullName.Substring($sourceRoot.Length).TrimStart('\')
        $targetPath = Join-Path $Destination $relativePath

        if ($_.PSIsContainer) {
            New-Item -ItemType Directory -Force $targetPath | Out-Null
            return
        }

        Copy-FileIfExists $_.FullName $targetPath
    }

    Write-Host "Installed folder: $Source -> $Destination"
}

$cursorUser = Join-Path $env:APPDATA 'Cursor\User'
$cursorHome = Join-Path $env:USERPROFILE '.cursor'
$byDesignDotfiles = Join-Path $DotfilesRoot 'project-rules\ByDesign.bd'

Copy-FileIfExists (Join-Path $DotfilesRoot 'settings.json') (Join-Path $cursorUser 'settings.json')
Copy-FileIfExists (Join-Path $DotfilesRoot 'keybindings.json') (Join-Path $cursorUser 'keybindings.json')
Copy-FileIfExists (Join-Path $DotfilesRoot 'mcp.json') (Join-Path $cursorHome 'mcp.json')

Copy-FolderIfExists (Join-Path $DotfilesRoot 'rules') (Join-Path $cursorHome 'rules')
Copy-FolderIfExists (Join-Path $DotfilesRoot 'skills') (Join-Path $cursorHome 'skills')

if (-not $SkipByDesignProjectRules) {
    Copy-FolderIfExists (Join-Path $byDesignDotfiles '.cursor\rules') (Join-Path $ByDesignRepo '.cursor\rules')
    Copy-FolderIfExists (Join-Path $byDesignDotfiles '.cursor\commands') (Join-Path $ByDesignRepo '.cursor\commands')
    Copy-FileIfExists (Join-Path $byDesignDotfiles '.cursor\CURSOR-AI-RULES-CONSOLIDATED.md') (Join-Path $ByDesignRepo '.cursor\CURSOR-AI-RULES-CONSOLIDATED.md')
    Copy-FileIfExists (Join-Path $byDesignDotfiles 'CLAUDE.md') (Join-Path $ByDesignRepo 'CLAUDE.md')
}

Write-Host ''
Write-Host 'Cursor dotfiles install complete.'
Write-Host 'Restart Cursor after installing settings, MCP servers, rules, or skills.'

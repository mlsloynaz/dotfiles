param(
    [string]$DotfilesRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [string]$ByDesignRepo = 'C:\Code\ByDesign.bd'
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
        Write-Host "Copied file: $Source -> $Destination"
    }
    catch {
        Write-Warning "Could not copy file: $Source. $($_.Exception.Message)"
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

    Write-Host "Copied folder: $Source -> $Destination"
}

$cursorUser = Join-Path $env:APPDATA 'Cursor\User'
$cursorHome = Join-Path $env:USERPROFILE '.cursor'
$byDesignDotfiles = Join-Path $DotfilesRoot 'project-rules\ByDesign.bd'

Copy-FileIfExists (Join-Path $cursorUser 'settings.json') (Join-Path $DotfilesRoot 'settings.json')
Copy-FileIfExists (Join-Path $cursorUser 'keybindings.json') (Join-Path $DotfilesRoot 'keybindings.json')
Copy-FileIfExists (Join-Path $cursorHome 'mcp.json') (Join-Path $DotfilesRoot 'mcp.json')

Copy-FolderIfExists (Join-Path $cursorHome 'rules') (Join-Path $DotfilesRoot 'rules')
Copy-FolderIfExists (Join-Path $cursorHome 'skills') (Join-Path $DotfilesRoot 'skills')

Copy-FolderIfExists (Join-Path $ByDesignRepo '.cursor\rules') (Join-Path $byDesignDotfiles '.cursor\rules')
Copy-FolderIfExists (Join-Path $ByDesignRepo '.cursor\commands') (Join-Path $byDesignDotfiles '.cursor\commands')
Copy-FileIfExists (Join-Path $ByDesignRepo '.cursor\CURSOR-AI-RULES-CONSOLIDATED.md') (Join-Path $byDesignDotfiles '.cursor\CURSOR-AI-RULES-CONSOLIDATED.md')
Copy-FileIfExists (Join-Path $ByDesignRepo 'CLAUDE.md') (Join-Path $byDesignDotfiles 'CLAUDE.md')

Write-Host ''
Write-Host 'Cursor dotfiles sync complete.'
Write-Host 'Note: MCP config may reference credential files by path; credentials are not copied by this script.'

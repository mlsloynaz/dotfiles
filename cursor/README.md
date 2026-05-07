# Cursor Dotfiles

This folder stores portable Cursor configuration for this machine.

## Why ByDesign Rules Were Not Here

The ByDesign rules are project rules, not global Cursor user rules. Cursor loads them from the ByDesign repository:

- `C:\Code\ByDesign.bd\.cursor\rules\`
- `C:\Code\ByDesign.bd\.cursor\CURSOR-AI-RULES-CONSOLIDATED.md`
- `C:\Code\ByDesign.bd\CLAUDE.md`

They should stay in the repo so they only apply when working in ByDesign. The dotfiles copy under `project-rules\ByDesign.bd\` is a backup/template for porting to another machine.

## What Is Synced

- Cursor user settings: `%APPDATA%\Cursor\User\settings.json`
- Cursor keybindings: `%APPDATA%\Cursor\User\keybindings.json`
- MCP config: `%USERPROFILE%\.cursor\mcp.json`
- Global Cursor rules: `%USERPROFILE%\.cursor\rules\`
- Cursor skills: `%USERPROFILE%\.cursor\skills\`
- ByDesign project AI files: `project-rules\ByDesign.bd\`

MCP config may reference credential files by path. Credentials are intentionally not copied here.

## Pull From This Machine

```powershell
powershell -ExecutionPolicy Bypass -File C:\Users\malu.loynaz\dotfiles\cursor\scripts\sync-from-machine.ps1
```

## Install On A Machine

```powershell
powershell -ExecutionPolicy Bypass -File C:\Users\malu.loynaz\dotfiles\cursor\scripts\install-to-machine.ps1
```

If the ByDesign repo is in a different location:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Users\malu.loynaz\dotfiles\cursor\scripts\install-to-machine.ps1 -ByDesignRepo C:\Code\ByDesign.bd
```

Restart Cursor after installing settings, MCP servers, rules, or skills.

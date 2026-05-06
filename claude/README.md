# Claude Code / Claude CLI (`~/.claude`)

This folder is the **source of truth** for settings you want on every PC. Machine-only data (cache, sessions, auth) stays under `%USERPROFILE%\.claude` and is **not** copied here.

## What lives where

| In this repo (`dotfiles/claude/`) | Applied to |
|-----------------------------------|------------|
| `policy-limits.json` | `%USERPROFILE%\.claude\policy-limits.json` |
| `commands/` | `%USERPROFILE%\.claude\commands\` |
| `settings.json` (optional, **gitignored**) | `%USERPROFILE%\.claude\settings.json` |
| `mcp.json` (optional, **gitignored**) | `%USERPROFILE%\.claude\mcp.json` |
| `settings.example.json`, `mcp.example.json` | Templates only (not applied automatically) |

## Secrets and Git

Do **not** commit API tokens or passwords. The repo root `.gitignore` ignores `claude/settings.json` and `claude/mcp.json` so you can keep real configs only on disk.

1. On a new machine, clone `dotfiles` to `%USERPROFILE%\dotfiles`.
2. Copy the examples and rename:

   ```powershell
   Copy-Item "$env:USERPROFILE\dotfiles\claude\settings.example.json" "$env:USERPROFILE\dotfiles\claude\settings.json"
   Copy-Item "$env:USERPROFILE\dotfiles\claude\mcp.example.json" "$env:USERPROFILE\dotfiles\claude\mcp.json"
   ```

3. Edit `claude\settings.json` and `claude\mcp.json` with your tokens and URLs.
4. Run `scripts\Apply-Dotfiles.ps1` (`-Mode Copy` or `-Mode Symlinks` as Administrator).

## Apply with the rest of your dotfiles

From the [main README](../README.md):

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
& "$env:USERPROFILE\dotfiles\scripts\Apply-Dotfiles.ps1" -Mode Copy
```

Symlinks mode links `policy-limits.json`, optional `settings.json` / `mcp.json`, and creates a **junction** `%USERPROFILE%\.claude\commands` → `dotfiles\claude\commands` when possible.

## Not synced (keep local)

Typical contents under `%USERPROFILE%\.claude` that you usually **do not** put in Git:

- `.credentials.json`, `history.jsonl`, `sessions/`, `cache/`, `telemetry/`, `file-history/`, `projects/`, etc.

Back those up separately if you need them; for a new PC, fresh Claude auth is normal.

## Rotating leaked tokens

If a Jira or other API token ever appeared in a committed file or chat, revoke it in the provider’s UI and create a new token, then update your local `settings.json` / `mcp.json` only.

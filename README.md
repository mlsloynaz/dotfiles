# Dotfiles

Config files synced to GitHub. Edit here (or in the app); keep this repo as source of truth.

**Location:** This repo is assumed to live in your user folder: `%USERPROFILE%\dotfiles` (e.g. `C:\Users\<you>\dotfiles`). Scripts and paths use that assumption.

## Layout

| Folder   | Files               | Original location |
|----------|---------------------|-------------------|
| `cursor/` | `settings.json`, `keybindings.json`, `mcp.json` | `%APPDATA%\Cursor\User\` and `%USERPROFILE%\.cursor\` |
| `cursor/skills/` | (folder) | `%USERPROFILE%\.cursor\skills` (junction) |
| `git/`   | `.gitconfig`, `.gitignore_global`  | `%USERPROFILE%\` |

## Apply dotfiles (one script)

Use the script in `scripts\Apply-Dotfiles.ps1` to create symlinks or copy files.

**Copy mode (no admin):** copies from dotfiles to your config locations. Run anytime to refresh.

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
& "$env:USERPROFILE\dotfiles\scripts\Apply-Dotfiles.ps1" -Mode Copy
```

**Symlinks mode (Administrator):** replaces config files with symlinks into this repo. Edit in Cursor/Git and commit from dotfiles.

```powershell
# Right-click PowerShell -> Run as administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
& "$env:USERPROFILE\dotfiles\scripts\Apply-Dotfiles.ps1" -Mode Symlinks
```

In both modes the script also ensures `.cursor\skills` is a junction to `dotfiles\cursor\skills`.

## Setup on a new machine

1. Clone this repo to `%USERPROFILE%\dotfiles`.
2. Run `Apply-Dotfiles.ps1` with `-Mode Copy` (or `-Mode Symlinks` as Administrator).

## Keeping in sync

- **With symlinks:** Edit settings in Cursor or Git as usual; changes are in this repo. `cd dotfiles`, then `git add` / `git commit` / `git push`.
- **Without symlinks:** After changing config, run `Apply-Dotfiles.ps1 -Mode Copy` to push dotfiles to targets, or copy updated files into `cursor/` or `git/` and commit.

## Not included (local only)

- `~/.gitconfig-personal` and `~/.gitconfig-work` (identity; add to dotfiles only if you want and they have no secrets).
- Any file with passwords or API keys.
- **mcp.json** may contain machine-specific paths; edit per machine if needed.

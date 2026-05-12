# Dotfiles — New Machine Setup Guide

Config files synced to GitHub. This repo is the source of truth for Cursor AI, Claude Code, Git, and GitHub configuration.

**Assumed repo location:** `%USERPROFILE%\dotfiles` (e.g. `C:\Users\<you>\dotfiles`)

> **Repo path may differ between machines.**
> This machine uses `C:\Code\ByDesign.bd`. Another machine might use `C:\Code\bdgit`.
> Decide your path before starting — you'll use it in steps 3, 7, 9, and the credentials setup.
> The variable `$repoPath` in the commands below represents that path.

---

## Quick-start checklist

1. [ ] Decide your ByDesign repo path (e.g. `C:\Code\ByDesign.bd` or `C:\Code\bdgit`)
2. [ ] Install prerequisites — then run `scripts\Check-Requirements.ps1` to verify
3. [ ] Clone this repo to `%USERPROFILE%\dotfiles`
4. [ ] Edit Git identity in `git\.gitconfig-personal` and `git\.gitconfig-work` (then apply dotfiles)
5. [ ] Authenticate with GitHub (`gh auth login`)
6. [ ] Run apply from dotfiles folder: `.\scripts\Apply-Dotfiles.ps1 -Mode Copy` (see §5)
7. [ ] Set up SQL MCP: run `scripts\Setup-Foundation.ps1`, `Setup-Claude.ps1`, `Setup-Cursor.ps1`
8. [ ] Fill in MCP secrets (Jira token): edit `claude\mcp.json`
9. [ ] Authenticate Claude Code (`claude`)
10. [ ] Sign into Cursor AI
11. [ ] Clone ByDesign repo to your chosen path and apply project rules
12. [ ] Add `dotfiles\bin` to `PATH`

---

## 1. Prerequisites

Check whether each tool is already installed first. Only follow the install steps if the check command fails or the tool is missing.

---

### Git for Windows

**Check:** `git --version`

**Install if missing:**
1. Go to <https://git-scm.com/download/win>
2. Download the 64-bit installer
3. Run it — use all defaults (Git Bash, OpenSSH, checkout as-is / commit LF)
4. After install, open a **new** terminal and run: `git lfs install`

---

### GitHub CLI (`gh`)

**Check:** `gh --version`

**Install if missing:**
1. Go to <https://cli.github.com>
2. Download the Windows `.msi` installer
3. Run it with defaults — it adds `gh` to PATH automatically

---

### Node.js and npm

**Check:** `node --version` and `npm --version`

**Install if missing:**
1. Go to <https://nodejs.org>
2. Download the **LTS** installer (`.msi`)
3. Run it — check "Automatically install the necessary tools" if prompted
4. Open a new terminal and verify with `node --version`

---

### Python 3

**Check:** `python --version`

**Install if missing:**
1. Go to <https://python.org/downloads>
2. Download Python 3.12.x Windows installer
3. Run it — **check "Add python.exe to PATH"** before clicking Install
4. Open a new terminal and verify with `python --version`

### Python packages (mcp, pyodbc) — required for SQL MCP

**Check:** `pip show mcp pyodbc`

**Install if missing:**
```powershell
pip install mcp pyodbc
```

Or run `scripts\Setup-Foundation.ps1` which checks and installs both.

---

### VSCode

**Check:** `code --version`

**Install if missing:**
1. Go to <https://code.visualstudio.com>
2. Download the User Installer for Windows 64-bit
3. Run it — check **"Add to PATH"** during install
4. Open a new terminal and verify with `code --version`

---

### Cursor AI

**Check:** Launch Cursor from the Start menu or taskbar

**Install if missing:**
1. Go to <https://cursor.com>
2. Click Download for Windows
3. Run the installer — it installs to `%LOCALAPPDATA%\Programs\cursor`
4. Sign in with your Cursor account on first launch

---

### Claude Code CLI

**Check:** `claude --version`

**Requires Node.js to be installed first.**

**Install if missing:**
1. Open a terminal
2. Run: `npm install -g @anthropic-ai/claude-code`
3. Verify with `claude --version`

---

### Angular CLI

**Check:** `ng version` — must show Angular CLI **14.x**

**Install if missing (or if wrong version):**
1. Open a terminal
2. Run: `npm install -g @angular/cli@14`
3. Verify with `ng version`

> If another version is globally installed and you can't replace it, use `npx @angular/cli@14` instead of `ng` when serving projects.

---

### ODBC Driver 17 for SQL Server

**Check:** Open "ODBC Data Sources (64-bit)" from Start → look for "ODBC Driver 17 for SQL Server" in the Drivers tab; or check Apps > Installed apps.

**Install if missing:**
1. Search "Download ODBC Driver 17 for SQL Server" on Microsoft's site (support.microsoft.com)
2. Download `msodbcsql.msi` (x64)
3. Run the installer with defaults

---

### Optional but recommended

| Tool | Where to get it |
|---|---|
| Windows Terminal | Microsoft Store → search "Windows Terminal" |
| Notepad++ | <https://notepad-plus-plus.org/downloads> |

---

## 2. Clone this repo

```powershell
cd $env:USERPROFILE
git clone https://github.com/malu-loynaz/dotfiles.git dotfiles
```

---

## 3. Git identity

The main `git\.gitconfig` uses `[include]` and `[includeIf]` — it does **not** embed your name or email. Identity lives in the repo under **`git/`**:

| File in dotfiles | Deployed to |
|------------------|-------------|
| `git\.gitconfig-personal` | `%USERPROFILE%\.gitconfig-personal` |
| `git\.gitconfig-work` | `%USERPROFILE%\.gitconfig-work` |

Edit **`git\.gitconfig-personal`** and **`git\.gitconfig-work`** in this repo (placeholders: `Your Name`, `your-personal-email@example.com`, `your-work-email@example.com`). Then run **`Apply-Dotfiles.ps1`** so copies or symlinks land in your profile. **Symlinks mode:** editing the files under `%USERPROFILE%\dotfiles\git\` is enough; **Copy mode:** re-run apply after edits.

If this repo is **public**, avoid committing real personal addresses; use private repo or local-only overrides.

The work identity activates automatically for repos under the paths listed in `[includeIf]` blocks inside `git\.gitconfig`. **If your ByDesign repo is not at `C:/Code/ByDesign.bd/`**, open `git\.gitconfig` (or `%USERPROFILE%\.gitconfig` after apply) and update those paths to match your actual location (e.g. `C:/Code/bdgit/`).

---

## 4. GitHub authentication

```powershell
gh auth login
# Choose: GitHub.com → HTTPS → browser
```

This also configures `git credential.helper` to use `gh auth git-credential`, which the `.gitconfig` already references.

---

## 5. Apply dotfiles

**Without admin (copy mode):** run from your profile dotfiles clone. Use **`.\scripts\...`** so PowerShell finds the script (typing `Apply-Dotfiles.ps1` alone is not a command).

```powershell
Set-Location $env:USERPROFILE\dotfiles
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\scripts\Apply-Dotfiles.ps1 -Mode Copy
```

From any directory you can use the full path instead:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
& "$env:USERPROFILE\dotfiles\scripts\Apply-Dotfiles.ps1" -Mode Copy
```

**With Administrator (symlinks — changes to Cursor/git configs are reflected in dotfiles immediately):**
```powershell
# Right-click PowerShell -> Run as administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
& "$env:USERPROFILE\dotfiles\scripts\Apply-Dotfiles.ps1" -Mode Symlinks
```

### What the script applies

| Source (dotfiles) | Target on machine |
|---|---|
| `cursor\settings.json` | `%APPDATA%\Cursor\User\settings.json` |
| `cursor\keybindings.json` | `%APPDATA%\Cursor\User\keybindings.json` |
| `cursor\mcp.json` | `%USERPROFILE%\.cursor\mcp.json` |
| `cursor\rules\` | `%USERPROFILE%\.cursor\rules\` |
| `cursor\skills\` | `%USERPROFILE%\.cursor\skills\` (junction) |
| `claude\policy-limits.json` | `%USERPROFILE%\.claude\policy-limits.json` |
| `claude\commands\` | `%USERPROFILE%\.claude\commands\` (junction) |
| `claude\settings.json` *(if present)* | `%USERPROFILE%\.claude\settings.json` |
| `claude\mcp.json` *(if present)* | `%USERPROFILE%\.claude\mcp.json` |
| `git\.gitconfig` | `%USERPROFILE%\.gitconfig` |
| `git\.gitconfig-personal` | `%USERPROFILE%\.gitconfig-personal` |
| `git\.gitconfig-work` | `%USERPROFILE%\.gitconfig-work` |
| `git\.gitconfig.aliases` | `%USERPROFILE%\.gitconfig-aliases` |
| `git\.gitignore_global` | `%USERPROFILE%\.gitignore_global` |
| `bd-repo.cursor\` | `%USERPROFILE%\bd-repo.cursor\` |
| `credentials\` | `%USERPROFILE%\credentials\` |

---

## 6. Claude Code

### Install and authenticate

```powershell
# Install (if not done in prerequisites)
npm install -g @anthropic-ai/claude-code

# Authenticate — opens browser
claude
```

### MCP configuration (secrets)

`claude\mcp.json` is **gitignored**. Copy the example and fill in your tokens:

```powershell
Copy-Item "$env:USERPROFILE\dotfiles\claude\mcp.example.json" `
          "$env:USERPROFILE\dotfiles\claude\mcp.json"
```

Edit `claude\mcp.json` and replace:
- `JIRA_URL` → `https://bydesigntechnologies.atlassian.net`
- `JIRA_EMAIL` → `malu.loynaz@bydesign.com`
- `JIRA_API_TOKEN` → create at <https://id.atlassian.com/manage-profile/security/api-tokens>

Then re-run `Apply-Dotfiles.ps1 -Mode Copy` (or `-Mode Symlinks`) to push the file to `%USERPROFILE%\.claude\mcp.json`.

### Claude Code settings

`claude\settings.json` is also **gitignored**. Copy the example if you need to customize hooks or permissions:

```powershell
Copy-Item "$env:USERPROFILE\dotfiles\claude\settings.example.json" `
          "$env:USERPROFILE\dotfiles\claude\settings.json"
```

See [claude/README.md](claude/README.md) for details.

### ByDesign project config

`CLAUDE.md` lives at the repo root and is committed — no separate step needed after cloning.
The `claude\commands\` folder (synced automatically) provides slash commands like `/dbstaging`.

---

## 7. Cursor AI

### Install

Download from <https://cursor.com> and install. Sign in with your account.

### Apply dotfiles

Already handled by `Apply-Dotfiles.ps1` above. Restart Cursor after running the script.

### MCP configuration (secrets)

`cursor\mcp.json` is in the repo but may need credentials updated per machine. Edit `%USERPROFILE%\.cursor\mcp.json` after applying:
- SQL Server MCP entries use Windows Integrated Authentication — no passwords needed if on domain.
- If Jira MCP is configured, use the same API token as Claude Code above.

### ByDesign project rules

The project-specific AI rules live in the repo under `.cursor\rules\`. Run the install script,
passing your actual repo path with `-ByDesignRepo`:

```powershell
# Default path (C:\Code\ByDesign.bd):
powershell -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\dotfiles\cursor\scripts\install-to-machine.ps1"

# If repo is at a different location (e.g. C:\Code\bdgit):
powershell -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\dotfiles\cursor\scripts\install-to-machine.ps1" `
  -ByDesignRepo C:\Code\bdgit

# Same thing, calling the script directly with & (any drive/path):
& "$env:USERPROFILE\dotfiles\cursor\scripts\install-to-machine.ps1" -ByDesignRepo "D:\work\ByDesign.bd"
```

See [cursor/README.md](cursor/README.md) for details.

---

## 8. VSCode

VSCode is configured as the default Git editor (`core.editor = code --wait` in `.gitconfig`).

### Extensions

Reinstall extensions from the command palette or CLI. Key ones for this repo:

```powershell
code --install-extension ms-mssql.mssql
code --install-extension eamodio.gitlens
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension ms-vscode.powershell
```

There is no VSCode settings file tracked in this dotfiles repo. Cursor shares the same extension marketplace and its `settings.json` already covers editor preferences. If you need separate VSCode user settings, create `%APPDATA%\Code\User\settings.json` manually.

---

## 9. Clone ByDesign repo

Decide your local path first (common options: `C:\Code\ByDesign.bd` or `C:\Code\bdgit`).

```powershell
# Set this to your chosen path
$repoPath = "C:\Code\ByDesign.bd"    # or "C:\Code\bdgit"

$parent = Split-Path $repoPath -Parent
$folder = Split-Path $repoPath -Leaf
mkdir $parent -Force
cd $parent
git clone https://github.com/Retail-Success/ByDesign.bd.git $folder
```

Then push the project AI rules into the cloned repo (pass the same path):

```powershell
powershell -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\dotfiles\cursor\scripts\install-to-machine.ps1" `
  -ByDesignRepo $repoPath
```

**If your path differs from `C:\Code\ByDesign.bd`**, also update these two things:

1. `git\.gitconfig` in dotfiles (or `%USERPROFILE%\.gitconfig` after apply) — the two `[includeIf "gitdir:..."]` lines (so work identity activates)
2. **`BYDESIGN_REPO` environment variable** (optional) — if your clone is not at `c:/Code/ByDesign.bd`, set it to that folder so `connect-staging-db.ps1` writes MCP under the same project key Claude Code uses (forward slashes are fine). Example before switching DB: `$env:BYDESIGN_REPO = "D:/work/ByDesign.bd"`

---

## 10. Add `bin\` to PATH

The `bin\` folder contains helper scripts (`start-serveDocs.cmd`, `stop-serveDocs.cmd`).
Add it to your user PATH so they are available in any terminal:

```powershell
$bin = "$env:USERPROFILE\dotfiles\bin"
$current = [Environment]::GetEnvironmentVariable('PATH', 'User')
if ($current -notlike "*$bin*") {
    [Environment]::SetEnvironmentVariable('PATH', "$current;$bin", 'User')
    Write-Host "Added $bin to user PATH. Open a new terminal to use it."
}
```

---

## Credentials and DB access

The `credentials\` folder (synced by the apply script) contains:

| File | Purpose |
|---|---|
| `connect-staging-db.ps1` | Switches MCP DB connection for Claude Code and Cursor |
| `msp-sql-credentials.json` | Staging server credentials (do not commit real tokens) |

Windows Integrated Authentication is used for staging SQL connections — the ODBC connection string uses `Trusted_Connection=yes`. You must be connected to the ByDesign domain/VPN for it to work.

**Claude Code `%USERPROFILE%\.claude.json`:** the switch script merges MCP under `projects.<folderPath>.mcpServers`. If `projects` was missing or not an object (fresh PC), older script versions could error; the current script creates a valid tree. If Claude still shows the wrong MCP, set **`BYDESIGN_REPO`** (or **`CLAUDE_PROJECT_KEY`**) to your ByDesign folder path so it matches the project entry Claude created (same path style as in `.claude.json` keys).

---

## Folder layout reference

```
dotfiles/
├── bd-repo.cursor/        # ByDesign repo Cursor files (commands, rules) — backup copy
├── bin/                   # CLI helper scripts added to PATH
├── claude/                # Claude Code user config
│   ├── commands/          # Claude slash commands
│   ├── mcp.example.json   # MCP template (fill in secrets → save as mcp.json)
│   ├── settings.example.json
│   └── README.md
├── credentials/           # DB connection helpers
│   ├── mcp-mssql/         # Python MCP server for SQL Server (pyodbc + Windows auth)
│   │   └── server.py
│   ├── connect-staging-db.ps1
│   └── msp-sql-credentials.json
├── cursor/                # Cursor AI user config
│   ├── project-rules/     # Per-repo AI rules (ByDesign.bd backup)
│   ├── rules/             # Global Cursor user rules (.mdc)
│   ├── scripts/           # install-to-machine.ps1, sync-from-machine.ps1
│   ├── skills/            # Cursor skill folders
│   ├── keybindings.json
│   ├── mcp.json
│   ├── settings.json
│   └── README.md
├── git/                   # Git global config
│   ├── .gitconfig             # Core config (identity via [include])
│   ├── .gitconfig-personal    # Personal [user] (edit placeholders)
│   ├── .gitconfig-work        # Work [user] (edit placeholders)
│   ├── .gitconfig.aliases     # All git aliases
│   └── .gitignore_global
├── scripts/
│   ├── Apply-Dotfiles.ps1     # Main apply script
│   ├── Check-Requirements.ps1 # Verify prerequisites
│   ├── Setup-Foundation.ps1   # pip install mcp pyodbc + ODBC check
│   ├── Setup-Claude.ps1       # Inject mssql MCP into ~/.claude.json
│   ├── Setup-Cursor.ps1       # Inject mssql MCP into ~/.cursor/mcp.json
│   ├── Setup-Git.ps1          # Apply git config + gh auth login
│   └── create-symlinks.ps1
└── .gitignore             # Excludes claude/settings.json and claude/mcp.json
```

---

## MCP Servers

MCP (Model Context Protocol) servers extend Claude Code and Cursor with live tools — SQL queries, Jira, Angular CLI. The configs are applied by `Apply-Dotfiles.ps1`, but each server needs its backing tool installed and, in some cases, secrets filled in.

---

### Claude Code MCPs

Config file (after applying dotfiles): `%USERPROFILE%\.claude\mcp.json`
Template to start from: `dotfiles\claude\mcp.example.json`

#### `angular-cli`

Gives Claude direct access to Angular CLI commands (generate, build, lint, etc.).

- **Needs:** Angular CLI 14 installed globally (`ng version`)
- **How it works:** runs `npx @angular/cli mcp` — no extra config needed
- **Setup:** already in `mcp.example.json`; no secrets required

#### `atlassian` (Jira)

Gives Claude access to Jira issues, projects, and comments.

- **Needs:** An Atlassian API token
- **How to create the token:**
  1. Go to <https://id.atlassian.com/manage-profile/security/api-tokens>
  2. Click "Create API token" → give it a label → copy the token
- **Where to put it:** in your local `dotfiles\claude\mcp.json` (gitignored):
  ```json
  "atlassian": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-jira"],
    "env": {
      "JIRA_URL": "https://bydesign-inc.atlassian.net",
      "JIRA_EMAIL": "malu.loynaz@bydesign.com",
      "JIRA_API_TOKEN": "ATATT3xFfGF0MiVeddKD3kw5YY_VXHUG1NGCYUalv13cpVLoMgY_mOP1vel-465HAhJryXWcCztYvzE8r--PMBafqPIc37TPZeAAt9YS_icAOPSmUt5O4OrDg7Znsiu0RL1MRBoUPWGuW2Z5H9xwyq61DG1GHUVn-0jXqmHzaj_hLWO-Qd4F6qg=A957F038"
    }
  }
  ```
- Alternatively, Atlassian offers an OAuth-based SSE endpoint (`https://mcp.atlassian.com/v1/sse`) that Claude Code can authenticate with via browser — no token needed, but requires re-auth on new machines.

#### `mssql` (SQL Server — switchable)

A single switchable entry backed by a Python + pyodbc server. No npm, no native drivers.

- **Needs:**
  - Python 3 with `mcp` and `pyodbc` packages (`pip install mcp pyodbc`)
  - ODBC Driver 17 for SQL Server
  - VPN / domain connection for staging servers
  - `credentials\mcp-mssql\server.py` deployed by `Apply-Dotfiles.ps1`
- **Auth:** Windows Integrated Authentication — `Trusted_Connection=yes` — no passwords in config
- **First-time setup on a new machine:**
  ```powershell
  # 1. Install Python packages and verify ODBC
  .\scripts\Setup-Foundation.ps1
  # 2. Inject mssql entry into Claude Code
  .\scripts\Setup-Claude.ps1
  # 3. Inject mssql entry into Cursor
  .\scripts\Setup-Cursor.ps1
  ```
- **Switching databases:** use the `/dbstaging` Claude command or run:
  ```powershell
  credentials\connect-staging-db.ps1 db-stg-qa8
  credentials\connect-staging-db.ps1 db-cs-nefful
  ```
  Then reload VS Code window (Ctrl+Shift+P → Developer: Reload Window).

---

### Cursor MCPs

Config file (after applying dotfiles): `%USERPROFILE%\.cursor\mcp.json`
Source in dotfiles: `dotfiles\cursor\mcp.json` (committed; update per machine as needed)

#### SQL Server (mssql)

Cursor uses the same Python + pyodbc server as Claude Code. Run `scripts\Setup-Cursor.ps1` after `Setup-Foundation.ps1` on a new machine.

- **Needs:** Python 3, `mcp` + `pyodbc` packages, ODBC Driver 17 for SQL Server, VPN for staging
- **Auth:** Windows Integrated Authentication — `Trusted_Connection=yes` — no passwords in config
- **Database:** switched at runtime by `connect-staging-db.ps1 db-stg-<client>`

---

### Verifying MCPs

After applying dotfiles and restarting Claude Code or Cursor, verify each MCP shows as connected:

- **Claude Code:** run `/mcp` in any conversation — lists connected servers and their status
- **Cursor:** open Settings → MCP → check each server shows a green dot

---

## Keeping in sync

### Pulling changes from another machine

```powershell
cd $env:USERPROFILE\dotfiles
git pull
& ".\scripts\Apply-Dotfiles.ps1" -Mode Copy
```

### Pushing changes from this machine

**Cursor:** Run `sync-from-machine.ps1` to capture changes made inside Cursor back to dotfiles:
```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\dotfiles\cursor\scripts\sync-from-machine.ps1"
```

Then commit:
```powershell
cd $env:USERPROFILE\dotfiles
git add cursor\ git\
git commit -m "sync cursor/git config from machine"
git push
```

**Claude commands:** Edit files in `dotfiles\claude\commands\` directly and commit.

---

## Not included (local only)

| What | Why |
|---|---|
| Real emails in `git\.gitconfig-*` | If repo is public, keep placeholders or use a private fork |
| `claude\settings.json`, `claude\mcp.json` | May contain API tokens — use `*.example.json` |
| `~\.claude\.credentials.json` | Auth token — re-run `claude` to authenticate |
| `~\.claude\sessions\`, `cache\`, `history.jsonl` | Machine-local runtime data |
| `msp-sql-credentials.json` real passwords | Edit locally; never commit secrets |

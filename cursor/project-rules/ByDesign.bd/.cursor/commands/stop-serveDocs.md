# stop-serveDocs — stop whatever is listening on port 9000

This matches the **`stop-serveDocs.cmd`** in `C:\Users\malu.loynaz\bin` (and the copy under `dotfiles\bin`): it stops **any** process bound to **TCP port 9000** (the default used by **`start-serveDocs`** / GlobalSkew `http-server`).

## Run from CMD (any folder, if `~\bin` is on PATH)

```bat
stop-serveDocs
```

## Run (PowerShell — one line)

```powershell
Get-NetTCPConnection -LocalPort 9000 -State Listen -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique | Where-Object { $_ -gt 0 } | ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }
```

If nothing is listening on **9000**, the command does nothing.

## Still able to open the page after stop?

1. **Confirm the listener is gone (on the same PC that runs the server)** — CMD:

   ```bat
   netstat -ano | findstr :9000
   ```

   If you see a line with **`LISTENING`**, note the last column (**PID**). In Task Manager → Details, end that **`node.exe`** (or run `taskkill /PID <pid> /F`). If **`netstat` shows nothing** but the tab still “works”, try the next bullets.

2. **Browser cache / bfcache** — Hard reload (**Ctrl+Shift+R**) or an **InPrivate/Incognito** window. If the server is really down, refresh should eventually show **connection refused** or a load error (not always instant if the tab was frozen).

3. **Another copy of `http-server`** — A second terminal, VS Code task, or an old **`npx http-server`** you started by hand can still be bound to **9000**. Stopping one process does not stop the others unless they share the same listener (they cannot share **9000**; so it is always a **different** process if port stayed busy).

4. **Agent / chat “stop” vs your machine** — If **`/stop-serveDocs`** was executed in an environment that is **not** the same OS instance as your browser (unusual for normal local Cursor, but possible with remoting), that stop would not kill **your** local Node. Run **`stop-serveDocs`** yourself in **CMD** or **PowerShell** on the PC where you started the server.

## After stopping

To serve the hub again, use **`/start-serveDocs`** or run **`start-serveDocs`** from CMD.

For Angular, .NET, tunnels, and firewall: **`@.cursor/rules/start-local-server.mdc`**.

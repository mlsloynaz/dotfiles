Switch the staging SQL Server MCP connection to a different database.

Run this command to update both Claude Code and Cursor configs:

```bash
powershell.exe -ExecutionPolicy Bypass -File "C:\\Users\\malu.loynaz\\credentials\\connect-staging-db.ps1" -dbname "$ARGUMENTS"
```

After running, tell the user: "Switched to **$ARGUMENTS**. Restart Claude Code and Cursor to connect."

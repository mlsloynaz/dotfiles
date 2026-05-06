Switch the staging SQL Server MCP connection to a different database.

Run this bash command to update both Claude Code and Cursor configs:

```bash
powershell.exe -ExecutionPolicy Bypass -File "%USERPROFILE%\credentials\connect-staging-db.ps1" -dbname "$ARGUMENTS"
```

After running, use the `mcp__mssql-dbstaging__query` tool to run:

```sql
SELECT DB_NAME() AS CurrentDatabase, @@SERVERNAME AS ServerName
```

- If the query succeeds, tell the user which database is now connected.
- If the query fails or returns the wrong database, tell the user: "Config updated but MCP hasn't restarted yet — reload the VS Code window (Ctrl+Shift+P → Developer: Reload Window) and try again."

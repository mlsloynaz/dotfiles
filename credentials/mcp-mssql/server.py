import os
import pyodbc
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("mssql")

def get_conn():
    conn_str = os.environ.get("MSSQL_CONNECTION_STRING")
    if not conn_str:
        raise ValueError("MSSQL_CONNECTION_STRING not set")
    return pyodbc.connect(conn_str)

@mcp.tool()
def query(sql: str) -> str:
    """Run a SQL query and return results."""
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(sql)
        if cursor.description is None:
            return f"OK — {cursor.rowcount} row(s) affected"
        cols = [d[0] for d in cursor.description]
        rows = cursor.fetchall()
        lines = ["\t".join(cols)]
        for row in rows:
            lines.append("\t".join("" if v is None else str(v) for v in row))
        return "\n".join(lines)

@mcp.tool()
def list_tables() -> str:
    """List all user tables in the current database."""
    return query("SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_SCHEMA, TABLE_NAME")

@mcp.tool()
def describe_table(table_name: str) -> str:
    """Show columns for a table."""
    return query(f"""
        SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = '{table_name}'
        ORDER BY ORDINAL_POSITION
    """)

if __name__ == "__main__":
    mcp.run()

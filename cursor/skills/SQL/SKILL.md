# SQL Skill — Looking Up Foreign Keys and Corresponding Tables

Use this when you need to find a foreign key by name and resolve its **parent** (referencing) and **referenced** tables in SQL Server.

## 1. Get the foreign key row

```sql
SELECT *
FROM sys.foreign_keys
WHERE Name = 'FK__PayOutReg__Payou__6A286D20'
```

From this row, use:
- **`parent_object_id`** — object_id of the table that **has** the FK (referencing table).
- **`referenced_object_id`** — object_id of the table being **referenced** by the FK.

## 2. Resolve parent (referencing) table

```sql
SELECT *
FROM sys.Objects
WHERE object_id = 2064882573  -- Parent Object ID (parent_object_id from step 1)
```

## 3. Resolve referenced table

```sql
SELECT *
FROM sys.Objects
WHERE object_id = 1717034044   -- Referenced Object ID (referenced_object_id from step 1)
```

## One-shot: FK name → both table names

To get the FK and both table names in one go, join to `sys.objects`:

```sql
SELECT
    fk.name AS foreign_key_name,
    parent.name AS parent_table,
    referenced.name AS referenced_table
FROM sys.foreign_keys fk
JOIN sys.objects parent ON parent.object_id = fk.parent_object_id
JOIN sys.objects referenced ON referenced.object_id = fk.referenced_object_id
WHERE fk.name = 'FK__PayOutReg__Payou__6A286D20'
```

Replace the `WHERE` value with the FK name you are looking up.

---

## Get Blocking and SQL Text

Use these when investigating blocking or when you need the SQL text and session/request details for running or blocked requests.

### Blocking sessions and SQL statement

Returns sessions with their SQL text, status, login, host, **blocker SPID** (`BlkBy`), database, command, CPU/IO, last batch, and program. Uncomment the `WHERE` to filter by login or database.

```sql
SELECT D.TEXT SQLStatement,
    A.Session_ID SPID,
    ISNULL(B.STATUS, A.STATUS) STATUS,
    A.login_name LOGIN,
    A.host_name HostName,
    C.BlkBy,
    DB_NAME(B.Database_ID) DBName,
    B.command,
    ISNULL(B.cpu_time, A.cpu_time) CPUTime,
    ISNULL((B.reads + B.writes), (A.reads + A.writes)) DiskIO,
    A.last_request_start_time LastBatch,
    A.program_name
FROM sys.dm_exec_sessions A
LEFT JOIN sys.dm_exec_requests B
    ON A.session_id = B.session_id
LEFT JOIN (
    SELECT A.request_session_id SPID,
        B.blocking_session_id BlkBy
    FROM sys.dm_tran_locks AS A
    INNER JOIN sys.dm_os_waiting_tasks AS B
        ON A.lock_owner_address = B.resource_address
) C
    ON A.Session_ID = C.SPID
OUTER APPLY sys.dm_exec_sql_text(B.sql_handle) D
-- WHERE A.login_name = 'BDTPROD\kirk.wagner'
-- AND DB_NAME(B.Database_ID) = 'SendoutCards'
```

### Proc name and SQL text for active requests

Returns the **procedure name** (if the request is in a proc), the **current statement text**, SPID, blocking SPID, CPU, reads/writes/logical_reads, database, start time, login, and full batch text. Uncomment the `WHERE` to filter by database.

```sql
SELECT o.NAME AS ProcName,
    SUBSTRING(TEXT, statement_start_offset / 2, (
        CASE
            WHEN statement_end_offset = -1
                THEN len(convert(NVARCHAR(max), TEXT)) * 2
            ELSE statement_end_offset
        END - statement_start_offset
    ) / 2) AS TEXT,
    r.session_id AS SPID,
    r.blocking_session_id AS [Blocking SPID],
    r.cpu_time AS [CPU],
    r.reads,
    r.writes,
    r.logical_reads,
    d.NAME AS [Database],
    r.start_time,
    s.login_name,
    s.last_request_start_time,
    t.objectid,
    t.TEXT
FROM sys.dm_exec_requests AS r
INNER JOIN sys.databases AS d
    ON r.database_id = d.database_id
INNER JOIN sys.dm_exec_sessions AS s
    ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
LEFT JOIN sys.objects AS o
    ON t.objectid = o.object_id
-- WHERE d.name = 'truaurabeauty'
```

---

## Fix Orders That Never Finished

**Reference:** By Arianna Capasso. Created for **Nexio**; adapt for other payment processors by changing the `Log_WebService_Payments` filter (request/response patterns).

**Before running:** If ARs (e.g. autorenewals) should go out, confirm **AR settings** are correct; otherwise they will not.

### 1. Create Order from OnlineOrder (cursor)

Use when **OnlineOrders** have a successful payment in the log but **no Order** (`OrderID` IS NULL). Finds rows where the payment processor (e.g. Nexio) returned OK and payment amount matches total, then calls `ws_OnlineAPI_CreateOrder` for each.

**Adjust:** `LWSP.request` / `LWSP.Response` for your processor; `OO.PaymentDate` and `@OrderDate` for your run.

```sql
DECLARE @OrderID INT,
        @ReturnMsg VARCHAR(200),
        @OnlineOrderID AS INT;
DECLARE db_cursor CURSOR FOR
SELECT OO.ID AS OnlineOrderID
FROM dbo.OnlineOrders AS OO WITH (NOLOCK)
LEFT JOIN Orders O WITH (NOLOCK) ON O.OrderID = OO.OrderID
LEFT JOIN OnlineSignup OS WITH (NOLOCK) ON OS.OnlineID = OO.SubjectID
LEFT JOIN OnlineOrdersPayments OOP WITH (NOLOCK) ON OOP.OnlineOrderID = OO.ID
INNER JOIN Log_WebService_Payments AS LWSP WITH (NOLOCK) ON LWSP.Subjectid = OO.ID
WHERE O.OrderID IS NULL
  -- AND O.StatusID IN (2, 3)
  AND LWSP.request LIKE 'https://api.nexiopay.com/pay/v3/process : Apply%'
  AND LWSP.Response LIKE 'OK%'
  AND OO.PaymentDate > '1/27/2025'
  AND ROUND(OO.PaymentAmount + COALESCE(OO.CreditAmount, 0), 2) = OO.Total;
OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @OnlineOrderID;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @OrderID = 0;
    SET @ReturnMsg = '';
    EXEC ws_OnlineAPI_CreateOrder
        @OnlineOrderID    = @OnlineOrderID,
        @OnlineSignupID   = NULL,
        @OnlineCustomerID = NULL,
        @OrderID          = @OrderID OUTPUT,
        @ReturnMsg        = @ReturnMsg OUTPUT,
        @PaymentRequired  = 0,
        @OrderDate        = '2025-01-28 13:31:00.630';
    PRINT @OrderID;
    -- PRINT @OnlineOrderID
    PRINT @ReturnMsg;
    FETCH NEXT FROM db_cursor INTO @OnlineOrderID;
END;
CLOSE db_cursor;
DEALLOCATE db_cursor;
```

### 2. Insert Payments from payment log (derived from Daniel’s code)

Use when **Orders** exist (e.g. in an AutoshipBatch) and the payment log shows success, but **Payments** rows are missing. Inserts into `Payments` from `Log_WebService_Payments` response JSON (Nexio-style). Adjust `PaymentTypeID`, `StatusTypeID`, `CCAccountID`, `CreatedBy`, `AutoshipBatchID`, and date filters as needed.

```sql
/*
-- Preview: orders in batch with Nexio success
SELECT TOP 100 P.*
FROM dbo.Orders AS O WITH (NOLOCK)
INNER JOIN Payments AS P ON P.OrderID = O.OrderID
WHERE AutoshipBatchID = 268
  AND P.PaymentTypeID = 20
*/
INSERT INTO Payments (
    PaymentTypeID, PaymentDate, OrderID, Amount,
    Detail1, Detail2, Detail3, Detail5, Detail6,
    StatusTypeID, MarketShowID, DateCreated, CreatedBy,
    Detail7, Detail8, Detail9, Detail10, Detail11, Detail12,
    CCAccount, CCAccountID,
    Detail13, Detail14, Detail15, Detail16
)
SELECT
    20 AS PaymentTypeID,
    '12/11/2024' AS PaymentDate,
    O.OrderID,
    CAST(JSON_VALUE(
        SUBSTRING(Response, CHARINDEX(':', Response) + 1, LEN(Response)),
        '$.amount'
    ) AS DECIMAL(10, 2)) AS Amount,
    CAST(JSON_VALUE(
        SUBSTRING(Response, CHARINDEX(':', Response) + 1, LEN(Response)),
        '$.token.token'
    ) AS NVARCHAR(1000)) AS Detail1,
    CAST(JSON_VALUE(
        SUBSTRING(Response, CHARINDEX(':', Response) + 1, LEN(Response)),
        '$.card.expirationMonth'
    ) AS NVARCHAR(1000))
    + RIGHT(CAST(JSON_VALUE(
        SUBSTRING(Response, CHARINDEX(':', Response) + 1, LEN(Response)),
        '$.card.expirationYear'
    ) AS NVARCHAR(1000)), 2) AS Detail2,
    CAST(JSON_VALUE(
        SUBSTRING(Response, CHARINDEX(':', Response) + 1, LEN(Response)),
        '$.card.cardHolder'
    ) AS NVARCHAR(1000)) AS Detail3,
    CAST(JSON_VALUE(
        SUBSTRING(Response, CHARINDEX(':', Response) + 1, LEN(Response)),
        '$.data.customer.billToAddressOne'
    ) AS NVARCHAR(1000)) AS Detail5,
    CAST(JSON_VALUE(
        SUBSTRING(Response, CHARINDEX(':', Response) + 1, LEN(Response)),
        '$.authCode'
    ) AS NVARCHAR(1000)) AS Detail6,
    22 AS StatusTypeID,
    NULL AS MarketShowID,
    GETDATE() AS DateCreated,
    'PW 843988 ' AS CreatedBy,
    NULL AS Detail7,
    CAST(JSON_VALUE(
        SUBSTRING(Response, CHARINDEX(':', Response) + 1, LEN(Response)),
        '$.id'
    ) AS NVARCHAR(1000)) AS Detail8,
    CAST(JSON_VALUE(
        SUBSTRING(Response, CHARINDEX(':', Response) + 1, LEN(Response)),
        '$.gatewayResponse.refNumber'
    ) AS NVARCHAR(1000)) AS Detail9,
    NULL AS Detail10,
    CAST(JSON_VALUE(
        SUBSTRING(Response, CHARINDEX(':', Response) + 1, LEN(Response)),
        '$.card.cardType'
    ) AS NVARCHAR(1000)) AS Detail11,
    CAST(JSON_VALUE(
        SUBSTRING(Response, CHARINDEX(':', Response) + 1, LEN(Response)),
        '$.token.lastFour'
    ) AS NVARCHAR(1000)) AS Detail12,
    'Credit Card' AS CCAccount,
    4 AS CCAccountID,
    CAST(JSON_VALUE(
        SUBSTRING(Response, CHARINDEX(':', Response) + 1, LEN(Response)),
        '$.data.customer.billToAddressOne'
    ) AS NVARCHAR(1000)) AS Detail13,
    CAST(JSON_VALUE(
        SUBSTRING(Response, CHARINDEX(':', Response) + 1, LEN(Response)),
        '$.data.customer.billToCity'
    ) AS NVARCHAR(1000)) AS Detail14,
    CAST(JSON_VALUE(
        SUBSTRING(Response, CHARINDEX(':', Response) + 1, LEN(Response)),
        '$.data.customer.billToState'
    ) AS NVARCHAR(1000)) AS Detail15,
    CAST(JSON_VALUE(
        SUBSTRING(Response, CHARINDEX(':', Response) + 1, LEN(Response)),
        '$.data.customer.billToCountry'
    ) AS NVARCHAR(1000)) AS Detail16
FROM dbo.Orders AS O WITH (NOLOCK)
INNER JOIN Log_WebService_Payments AS LWSP WITH (NOLOCK)
    ON LWSP.SubjectID = O.OrderID
WHERE O.AutoshipBatchID = 270
  -- AND O.StatusID IN (2, 3)
  AND LWSP.Request LIKE 'https://api.nexiopay.com/pay/v3/process : Apply%'
  AND LWSP.Response LIKE 'OK%';
  -- AND O.OrderID = 326756
```

---

## Syslogs & WebLogs dashboards

Use these for investigating DB performance, production errors, and web/extranet issues.

| Purpose | URL |
|--------|-----|
| **SysLogs** (DB/production errors, saved searches) | http://syslog:9000/dashboards/53dfcd65e4b0e75d46731643 |
| **WebLogs** | http://weblogs:9000/dashboards/565f05a2b410f4c1e5377520 |

---

## Email alerts (reference)

Quick reference for monitoring alerts: what they mean, source, severity, and who receives them.

| Alert | Priority | Indications | Source | Severity | Email group |
|-------|----------|--------------|--------|----------|-------------|
| **ByDesign Database Statistics - Aggregate** | High | DB performance changes; most impacted proc across all clients | DBADash | Sev-3 intermittent, Sev-2 active | DBADashAlert \<dbadashalert@bydesign.com\> |
| **ByDesign Database Statistics - \<client\> (DBxx) - Under 100%** | High | DB performance by client; typically dedicated DB hosting; may need enabling per client by NT | DBADash | Sev-3 intermittent, Sev-2 active | e.g. Avroy DB Alert \<AvroyDBAlert@bydesign.com\> |
| **BackOffice Error - Autoship/ExecAutoShip.asp** | High | Critical for production. Check client settings for **spAutoship_Execute** failure. **Setting:** `AutoShipExec_LastStepProcessed` → ideal **"Autoship Completed Successfully"**. Common causes: promotion changes, deadlocks/latency/timeouts, conflict with shipping batch, inventory/order imports, bonus commits; multiple simultaneous executions not allowed. Scripts exist for reverting (order deletion, payment tx deletion, next ship date reversion). | Freedom (Admin) | Sev-2 | System BCC \<system_bcc@mlmbydesign.com\> |
| **Extranet Framework** | Low | Usually non-critical; should be corrected to go to SysLogs like other Extranet errors | Freedom (Extranet) | Sev-4 to Sev-6 | System BCC |
| **Production development errors** | Moderate–High | Sudden increase in errors; thresholds set by NT. Most value during releases or major client events. Use SysLogs saved searches to isolate. | SysLogs | Variable | Production Development Errors Alert \<ProductionDevelopmentErrors@bydesign.com\> |
| **Publish Settings Failure for \<client\>** | Low | Issues identifying active servers for client when publishing Freedom settings; limited value until improved | Freedom (Admin) | N/A | System BCC |
| **Error executing UPS Realtime Request** | Low | Integration no longer recommended; only known use Youngevity; integration past EOL per 3rd-party | Freedom (DB CLR Proc) | N/A | System BCC |

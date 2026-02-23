DECLARE @SQL NVARCHAR(MAX);
SET @SQL = '';

-- Criar a tabela temporária na tempdb
IF OBJECT_ID('#ObsoleteTables') IS NOT NULL
    DROP TABLE tempdb..#ObsoleteTables;

CREATE TABLE #ObsoleteTables (
    DatabaseName NVARCHAR(128),
    SchemaName NVARCHAR(128),
    TableName NVARCHAR(128),
    LastRead NVARCHAR(20),
    LastScan NVARCHAR(20),
    LastLookup NVARCHAR(20),
    LastUpdate NVARCHAR(20),
    LastDDLChange NVARCHAR(20)
);



-- Percorre todas as bases de dados de utilizador
SELECT @SQL = @SQL + '
USE [' + name + '];
WITH TableActivity AS (
    SELECT 
        t.object_id,
        DB_NAME() AS DatabaseName,
        s.name AS SchemaName,
        t.name AS TableName,
        MAX(ISNULL(us.last_user_seek, ''1900-01-01'')) AS LastRead,
        MAX(ISNULL(us.last_user_scan, ''1900-01-01'')) AS LastScan,
        MAX(ISNULL(us.last_user_lookup, ''1900-01-01'')) AS LastLookup,
        MAX(ISNULL(us.last_user_update, ''1900-01-01'')) AS LastUpdate,
        MAX(ISNULL(o.modify_date, ''1900-01-01'')) AS LastDDLChange
    FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    LEFT JOIN sys.dm_db_index_usage_stats us 
        ON t.object_id = us.object_id 
        AND us.database_id = DB_ID()
    LEFT JOIN sys.objects o 
        ON t.object_id = o.object_id
    WHERE 
        (us.last_user_seek IS NULL OR us.last_user_seek < DATEADD(MONTH, -6, GETDATE()))
        AND (us.last_user_scan IS NULL OR us.last_user_scan < DATEADD(MONTH, -6, GETDATE()))
        AND (us.last_user_lookup IS NULL OR us.last_user_lookup < DATEADD(MONTH, -6, GETDATE()))
        AND (us.last_user_update IS NULL OR us.last_user_update < DATEADD(MONTH, -6, GETDATE()))
        AND (o.modify_date IS NULL OR o.modify_date < DATEADD(MONTH, -6, GETDATE()))
    GROUP BY t.object_id, s.name, t.name
)
INSERT INTO #ObsoleteTables (DatabaseName, SchemaName, TableName, LastRead, LastScan, LastLookup, LastUpdate, LastDDLChange)
SELECT DatabaseName, SchemaName, TableName, 
       CONVERT(NVARCHAR(20), LastRead, 120), 
       CONVERT(NVARCHAR(20), LastScan, 120), 
       CONVERT(NVARCHAR(20), LastLookup, 120), 
       CONVERT(NVARCHAR(20), LastUpdate, 120),
       CONVERT(NVARCHAR(20), LastDDLChange, 120)
FROM TableActivity;
' 
FROM sys.databases
WHERE database_id > 4 AND state_desc = 'ONLINE'
AND name NOT IN ('tempdb', 'SSISDB'); -- Exclui bases de dados do sistema;
-- Executa a consulta dinâmica para popular a tabela temporária
EXEC sp_executesql @SQL;

-- Exibir os dados armazenados na tempdb
SELECT * FROM #ObsoleteTables;

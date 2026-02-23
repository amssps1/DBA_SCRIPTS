USE tempdb;
GO

-- Criar a tabela temporária na tempdb
IF OBJECT_ID('#ObsoleteTables') IS NOT NULL
    DROP TABLE #ObsoleteTables;

CREATE TABLE #ObsoleteTables (
    DatabaseName NVARCHAR(128),
    SchemaName NVARCHAR(128),
    TableName NVARCHAR(128),
    LastRead NVARCHAR(20),
    LastScan NVARCHAR(20),
    LastLookup NVARCHAR(20),
    LastUpdate NVARCHAR(20)
);

DECLARE @SQL NVARCHAR(MAX);
SET @SQL = '';

-- Percorre todas as bases de dados de utilizador
SELECT @SQL = @SQL + '
USE [' + name + '];
INSERT INTO #ObsoleteTables (DatabaseName, SchemaName, TableName, LastRead, LastScan, LastLookup, LastUpdate)
SELECT 
    DB_NAME() AS DatabaseName,
    s.name AS SchemaName,
    t.name AS TableName,
    COALESCE(CONVERT(NVARCHAR(20), us.last_user_seek, 120), ''Não utilizada'') AS LastRead,
    COALESCE(CONVERT(NVARCHAR(20), us.last_user_scan, 120), ''Não utilizada'') AS LastScan,
    COALESCE(CONVERT(NVARCHAR(20), us.last_user_lookup, 120), ''Não utilizada'') AS LastLookup,
    COALESCE(CONVERT(NVARCHAR(20), us.last_user_update, 120), ''Não utilizada'') AS LastUpdate
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
LEFT JOIN sys.dm_db_index_usage_stats us 
    ON t.object_id = us.object_id 
    AND us.database_id = DB_ID()
WHERE
    (
        (us.last_user_seek IS NULL OR us.last_user_seek < DATEADD(MONTH, -6, GETDATE())) AND
        (us.last_user_scan IS NULL OR us.last_user_scan < DATEADD(MONTH, -6, GETDATE())) AND
        (us.last_user_lookup IS NULL OR us.last_user_lookup < DATEADD(MONTH, -6, GETDATE())) AND
        (us.last_user_update IS NULL OR us.last_user_update < DATEADD(MONTH, -6, GETDATE()))
    )
ORDER BY DB_NAME(), SchemaName, TableName;
' 
FROM sys.databases
WHERE database_id > 4 AND state_desc = 'ONLINE'
AND name NOT IN ('tempdb', 'SSISDB'); -- Exclui bases de dados do sistema

-- Executa a consulta dinâmica para popular a tabela temporária
EXEC sp_executesql @SQL;

---- Exibir os dados armazenados na tempdb
--SELECT * FROM #ObsoleteTables
--ORDER BY DatabaseName, TableName
----DROP TABLE IF EXISTS #ObsoleteTables;
--go


USE dba_db;
GO

-- Create a persistent table in the user database
IF OBJECT_ID('dbo.Artemis_ObsoleteTables', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Artemis_ObsoleteTables (
        DatabaseName NVARCHAR(128),
        SchemaName NVARCHAR(128),
        TableName NVARCHAR(128),
        LastRead NVARCHAR(20),
        LastScan NVARCHAR(20),
        LastLookup NVARCHAR(20),
        LastUpdate NVARCHAR(20),
        InsertedAt DATETIME DEFAULT GETDATE()  -- Optional: Track when the data was copied
    );
END
TRUNCATE TABLE dbo.Artemis_ObsoleteTables;
-- Insert data from tempdb to the persistent table
INSERT INTO dbo.Artemis_ObsoleteTables (DatabaseName, SchemaName, TableName, LastRead, LastScan, LastLookup, LastUpdate)
SELECT DatabaseName, SchemaName, TableName, LastRead, LastScan, LastLookup, LastUpdate
FROM #ObsoleteTables;
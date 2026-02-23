SET NOCOUNT ON;




USE [master];
GO

IF object_id('tempdb..#TableSizes') IS NOT NULL
    DROP TABLE #TableSizes;

CREATE TABLE #TableSizes
(
    recid          int IDENTITY (1, 1),
    DatabaseName   sysname,
    SchemaName     varchar(128),
    TableName      varchar(128),
    NumRows        bigint,
    Total_MB       decimal(15,2),
    Used_MB        decimal(15,2),
    Unused_MB      decimal(15,2)
)

EXEC sp_MSforeachdb 'USE [?];
INSERT INTO #TableSizes (DatabaseName, TableName, SchemaName, NumRows, Total_MB, Used_MB, Unused_MB)
SELECT
    ''?'' as DatabaseName,
    s.Name AS SchemaName,
    t.NAME AS TableName,
    p.rows AS NumRows,
    CAST(ROUND((SUM(a.total_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS Total_MB,
    CAST(ROUND((SUM(a.used_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS Used_MB,
    CAST(ROUND((SUM(a.total_pages) - SUM(a.used_pages)) / 128.00, 2) AS NUMERIC(36, 2)) AS Unused_MB
FROM
    sys.tables t
    JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
    JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
    JOIN sys.allocation_units a ON p.partition_id = a.container_id
    LEFT OUTER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE
    t.name NOT LIKE ''dt%''
    AND t.is_ms_shipped = 0
    AND i.object_id > 255
	AND p.rows > 10000
GROUP BY
    t.Name, s.Name, p.Rows
ORDER BY
    Total_MB DESC, t.Name';

insert into dba_db.dbo.TableSizeGrowth (database_name,table_name, table_schema,table_rows,reserved_space, data_space )
SELECT   DatabaseName, TableName, SchemaName, NumRows, Total_MB, Used_MB
FROM     #TableSizes
ORDER BY DatabaseName, TableName;

drop table if exists #TableSizes;


--select * from  dba_db.dbo.TableSizeGrowth



USE dba_db;
GO
DROP TABLE IF EXISTS Tabela_Crescimento_Rows
go

CREATE TABLE dbo.Tabela_Crescimento_Rows (
    CaptureDate     DATETIME       NOT NULL DEFAULT GETDATE(),
    DatabaseName    SYSNAME        NOT NULL,
    SchemaName      SYSNAME        NOT NULL,
    TableName       SYSNAME        NOT NULL,
    [RowCount]        BIGINT         NOT NULL,
    DeltaRows       BIGINT         NULL
);

ALTER TABLE dbo.Tabela_Crescimento_Rows
ADD UsedKB BIGINT NULL;



USE dba_db;
GO

IF OBJECT_ID('dbo.usp_Captura_Crescimento_Rows', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Captura_Crescimento_Rows;
GO

CREATE PROCEDURE dbo.usp_Captura_Crescimento_Rows
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX) = N'';

    SELECT @SQL = STRING_AGG(CAST(N'
    USE [' + name + '];
    IF DB_ID(''' + name + ''') IS NOT NULL
    BEGIN
        WITH TableStats AS (
            SELECT 
                s.name AS SchemaName,
                t.name AS TableName,
                SUM(p.rows) AS CurrentRowCount,
                SUM(a.total_pages) * 8 AS UsedKB
            FROM sys.tables t
            INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
            INNER JOIN sys.indexes i ON t.object_id = i.object_id
            INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
            INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
            WHERE p.index_id IN (0, 1)
            GROUP BY s.name, t.name
            HAVING SUM(p.rows) > 50000
        )
        INSERT INTO dba_db.dbo.Tabela_Crescimento_Rows (
            CaptureDate, DatabaseName, SchemaName, TableName, [RowCount], DeltaRows, UsedKB
        )
        SELECT 
            GETDATE(),
            DB_NAME(),
            ts.SchemaName,
            ts.TableName,
            ts.CurrentRowCount,
            ts.CurrentRowCount - ISNULL((
                SELECT TOP 1 rc.[RowCount]
                FROM dba_db.dbo.Tabela_Crescimento_Rows rc
                WHERE 
                    rc.DatabaseName = DB_NAME() COLLATE Latin1_General_CI_AS AND
                    rc.SchemaName = ts.SchemaName COLLATE Latin1_General_CI_AS AND
                    rc.TableName = ts.TableName COLLATE Latin1_General_CI_AS
                ORDER BY rc.CaptureDate DESC
            ), 0) AS DeltaRows,
            ts.UsedKB
        FROM TableStats ts
        WHERE (ts.CurrentRowCount - ISNULL((
                SELECT TOP 1 rc.[RowCount]
                FROM dba_db.dbo.Tabela_Crescimento_Rows rc
                WHERE 
                    rc.DatabaseName = DB_NAME() COLLATE Latin1_General_CI_AS AND
                    rc.SchemaName = ts.SchemaName COLLATE Latin1_General_CI_AS AND
                    rc.TableName = ts.TableName COLLATE Latin1_General_CI_AS
                ORDER BY rc.CaptureDate DESC
            ), 0)) <> 0;
    END
    ' AS NVARCHAR(MAX)), CHAR(13) + CHAR(10))
    FROM sys.databases
    WHERE database_id > 4 AND state_desc = 'ONLINE';

    EXEC sp_executesql @SQL;
END
GO


--EXEC dbo.usp_Captura_Crescimento_Rows


--SELECT * FROM Tabela_Crescimento_Rows
--ORDER BY tablename


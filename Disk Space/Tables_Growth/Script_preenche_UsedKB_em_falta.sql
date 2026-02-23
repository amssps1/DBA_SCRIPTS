DECLARE @DatabaseName SYSNAME, @SchemaName SYSNAME, @TableName SYSNAME;
DECLARE @SQL NVARCHAR(MAX);

-- Cursor para percorrer os registros com UsedKB em branco
DECLARE Cur_Tabelas CURSOR FOR
SELECT DISTINCT DatabaseName, SchemaName, TableName
FROM dba_db.dbo.Tabela_Crescimento_Rows
WHERE UsedKB IS NULL;

OPEN Cur_Tabelas;
FETCH NEXT FROM Cur_Tabelas INTO @DatabaseName, @SchemaName, @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = N'
    USE [' + REPLACE(@DatabaseName, ']', ']]') + '];

    IF EXISTS (
        SELECT 1 
        FROM sys.tables t
        INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
        WHERE s.name = N''' + @SchemaName + ''' AND t.name = N''' + @TableName + '''
    )
    BEGIN
        ;WITH SpaceUsed AS (
            SELECT 
                s.name AS SchemaName,
                t.name AS TableName,
                SUM(a.total_pages) * 8 AS UsedKB
            FROM sys.tables t
            INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
            INNER JOIN sys.indexes i ON t.object_id = i.object_id
            INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
            INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
            WHERE s.name = N''' + @SchemaName + ''' AND t.name = N''' + @TableName + '''
            GROUP BY s.name, t.name
        )
        UPDATE r
        SET r.UsedKB = su.UsedKB
        FROM dba_db.dbo.Tabela_Crescimento_Rows r
        INNER JOIN SpaceUsed su
            ON r.DatabaseName = N''' + @DatabaseName + ''' 
            AND r.SchemaName = su.SchemaName 
            AND r.TableName = su.TableName
        WHERE r.UsedKB IS NULL;
    END
    ';

    -- Debug opcional: PRINT @SQL;
    EXEC sp_executesql @SQL;

    FETCH NEXT FROM Cur_Tabelas INTO @DatabaseName, @SchemaName, @TableName;
END

CLOSE Cur_Tabelas;
DEALLOCATE Cur_Tabelas;

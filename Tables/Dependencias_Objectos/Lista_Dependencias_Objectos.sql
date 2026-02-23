DECLARE @TableName SYSNAME = 'Cof_Documentacao';

DECLARE @SchemaName SYSNAME = 'dbo';

IF OBJECT_ID('tempdb..#Dependencias') IS NOT NULL DROP TABLE #Dependencias;

CREATE TABLE #Dependencias (
    DatabaseName SYSNAME,
    ReferencingSchema SYSNAME,
    ReferencingObject SYSNAME,
    ReferencingType NVARCHAR(60)
);

DECLARE @SQL NVARCHAR(MAX);
DECLARE @DbName SYSNAME;

DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT name
FROM sys.databases
WHERE database_id > 4 -- Bases de dados de utilizador
  AND state_desc = 'ONLINE'
  AND is_distributor = 0;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DbName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = '
    USE ' + QUOTENAME(@DbName) + ';
    INSERT INTO tempdb..#Dependencias (DatabaseName, ReferencingSchema, ReferencingObject, ReferencingType)
    SELECT
        DB_NAME(),
        OBJECT_SCHEMA_NAME(d.referencing_id),
        OBJECT_NAME(d.referencing_id),
        o.type_desc
    FROM sys.sql_expression_dependencies d
    JOIN sys.objects o ON d.referencing_id = o.object_id
    WHERE d.referenced_entity_name = @TableName
      AND OBJECT_SCHEMA_NAME(d.referenced_id) = @SchemaName;
    ';

    EXEC sp_executesql @SQL,
        N'@TableName SYSNAME, @SchemaName SYSNAME',
        @TableName, @SchemaName;

    FETCH NEXT FROM db_cursor INTO @DbName;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;

-- Resultado final
SELECT *
FROM #Dependencias
ORDER BY DatabaseName, ReferencingObject;

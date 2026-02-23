DECLARE @TableName NVARCHAR(128);
DECLARE @IndexName NVARCHAR(128);
DECLARE @SchemaName NVARCHAR(128);
DECLARE @SQL NVARCHAR(MAX);
DECLARE @Fragmentation FLOAT;

DECLARE cur CURSOR FOR
SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    i.name AS IndexName,
    ps.avg_fragmentation_in_percent AS Fragmentation
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ps
JOIN sys.indexes i ON ps.object_id = i.object_id AND ps.index_id = i.index_id
JOIN sys.tables t ON t.object_id = i.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE i.type_desc IN ('CLUSTERED', 'NONCLUSTERED') -- Ignore heap tables
AND ps.avg_fragmentation_in_percent > 10  -- Only consider fragmented indexes
ORDER BY ps.avg_fragmentation_in_percent DESC;

OPEN cur;
FETCH NEXT FROM cur INTO @SchemaName, @TableName, @IndexName, @Fragmentation;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = 
        CASE 
            WHEN @Fragmentation > 30 
            THEN 'ALTER INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @TableName + '] REBUILD'
            ELSE 'ALTER INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @TableName + '] REORGANIZE'
        END;
    
    PRINT @SQL;  -- Check the generated SQL before executing
    EXEC sp_executesql @SQL;  

    FETCH NEXT FROM cur INTO @SchemaName, @TableName, @IndexName, @Fragmentation;
END

CLOSE cur;
DEALLOCATE cur;

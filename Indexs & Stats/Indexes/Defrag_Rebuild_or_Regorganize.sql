DECLARE @TableName NVARCHAR(255);
DECLARE @SchemaName NVARCHAR(255);
DECLARE @IndexName NVARCHAR(255);
DECLARE @SQL NVARCHAR(MAX);
DECLARE @Fragmentation FLOAT;
DECLARE @IndexID INT;

-- Cursor to loop through fragmented indexes
DECLARE index_cursor CURSOR FOR
SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    i.name AS IndexName,
    ips.index_id,
    ips.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
JOIN sys.tables t ON ips.object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.index_id > 0 -- Exclude Heap Tables (No Index)
ORDER BY ips.avg_fragmentation_in_percent DESC;

OPEN index_cursor;
FETCH NEXT FROM index_cursor INTO @SchemaName, @TableName, @IndexName, @IndexID, @Fragmentation;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- If Fragmentation > 30%, Rebuild Index
    IF @Fragmentation > 30
    BEGIN
        SET @SQL = 'ALTER INDEX ' + QUOTENAME(@IndexName) + ' ON ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' REBUILD WITH (ONLINE = ON);';
        PRINT 'Rebuilding: ' + @SQL;
        EXEC sp_executesql @SQL;
    END
    -- If Fragmentation is between 10% and 30%, Reorganize Index
    ELSE IF @Fragmentation BETWEEN 10 AND 30
    BEGIN
        SET @SQL = 'ALTER INDEX ' + QUOTENAME(@IndexName) + ' ON ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' REORGANIZE;';
        PRINT 'Reorganizing: ' + @SQL;
        EXEC sp_executesql @SQL;
    END

    -- Move to the next index in the cursor
    FETCH NEXT FROM index_cursor INTO @SchemaName, @TableName, @IndexName, @IndexID, @Fragmentation;
END

CLOSE index_cursor;
DEALLOCATE index_cursor;

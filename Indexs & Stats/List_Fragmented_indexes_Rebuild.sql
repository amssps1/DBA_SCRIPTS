DECLARE @dbName NVARCHAR(128) = 'idh'; -- Replace with your database name

USE @dbName;
GO

WITH FragmentedIndexes AS (
    SELECT 
        DB_NAME() AS DatabaseName,
        OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
        OBJECT_NAME(i.object_id) AS TableName,
        i.name AS IndexName,
        ps.avg_fragmentation_in_percent AS Fragmentation,
        i.index_id,
        CASE 
            WHEN ps.avg_fragmentation_in_percent >= 30 THEN 'REBUILD'
            WHEN ps.avg_fragmentation_in_percent >= 5 THEN 'REORGANIZE'
            ELSE 'NONE'
        END AS SuggestedAction
    FROM 
        sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ps
    INNER JOIN 
        sys.indexes AS i ON ps.object_id = i.object_id AND ps.index_id = i.index_id
    WHERE 
        i.type > 0  -- 0 = Heap; we're only interested in clustered and nonclustered indexes
        AND ps.avg_fragmentation_in_percent > 5 -- Only consider indexes with >5% fragmentation
)
SELECT 
    DatabaseName,
    SchemaName,
    TableName,
    IndexName,
    Fragmentation,
    SuggestedAction,
    CASE 
        WHEN SuggestedAction = 'REBUILD' 
            THEN 'ALTER INDEX ' + QUOTENAME(IndexName) + ' ON ' + QUOTENAME(SchemaName) + '.' + QUOTENAME(TableName) + ' REBUILD;'
        WHEN SuggestedAction = 'REORGANIZE' 
            THEN 'ALTER INDEX ' + QUOTENAME(IndexName) + ' ON ' + QUOTENAME(SchemaName) + '.' + QUOTENAME(TableName) + ' REORGANIZE;'
        ELSE 'No action required'
    END AS CorrectionCommand
FROM 
    FragmentedIndexes
ORDER BY 
    Fragmentation DESC;

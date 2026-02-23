-- Define thresholds for fragmentation
DECLARE @ReorganizeThreshold INT = 5;  -- Fragmentation % for reorganizing
DECLARE @RebuildThreshold INT = 30;    -- Fragmentation % for rebuilding

-- Query to find fragmented indexes and generate maintenance commands
WITH FragmentedIndexes AS (
    SELECT 
        OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
        OBJECT_NAME(i.object_id) AS TableName,
        i.name AS IndexName,
        ps.avg_fragmentation_in_percent AS Fragmentation,
        ps.page_count AS PageCount,
        CASE 
            WHEN ps.avg_fragmentation_in_percent >= @RebuildThreshold THEN 'REBUILD'
            WHEN ps.avg_fragmentation_in_percent >= @ReorganizeThreshold THEN 'REORGANIZE'
            ELSE 'NONE'
        END AS SuggestedAction
    FROM 
        sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ps
    INNER JOIN 
        sys.indexes AS i ON ps.object_id = i.object_id AND ps.index_id = i.index_id
    WHERE 
        i.type > 0  -- Only consider non-heap indexes (type > 0)
        AND ps.page_count > 500  -- Ignore indexes with few pages
        AND ps.avg_fragmentation_in_percent > @ReorganizeThreshold -- Only show indexes above the fragmentation threshold
)
SELECT 
    SchemaName,
    TableName,
    IndexName,
    Fragmentation,
    PageCount,
    SuggestedAction,
    CASE 
        WHEN SuggestedAction = 'REBUILD' 
            THEN 'ALTER INDEX ' + QUOTENAME(IndexName) + ' ON ' + QUOTENAME(SchemaName) + '.' + QUOTENAME(TableName) + ' REBUILD;'
        WHEN SuggestedAction = 'REORGANIZE' 
            THEN 'ALTER INDEX ' + QUOTENAME(IndexName) + ' ON ' + QUOTENAME(SchemaName) + '.' + QUOTENAME(TableName) + ' REORGANIZE;'
        ELSE 'No action required'
    END AS MaintenanceCommand
FROM 
    FragmentedIndexes
WHERE 
    SuggestedAction IN ('REBUILD', 'REORGANIZE')
ORDER BY 
    Fragmentation DESC;

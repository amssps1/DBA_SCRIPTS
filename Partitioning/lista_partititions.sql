--SELECT 
--    sch.name AS SchemaName,
--    t.name AS TableName,
--    i.name AS IndexName,
--    ps.name AS PartitionScheme,
--    pf.name AS PartitionFunction,
--    p.partition_number,
--    fg.name AS FileGroup,
--    SUM(p.[rows]) AS TotalRows -- Corrected usage of 'rows'
--FROM sys.tables t
--JOIN sys.schemas sch ON t.schema_id = sch.schema_id
--JOIN sys.indexes i ON t.object_id = i.object_id
--JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
--JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
--JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
--JOIN sys.destination_data_spaces dds ON ps.data_space_id = dds.partition_scheme_id
--JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id
--WHERE i.type <= 1 -- Only Clustered and Heap tables
--AND t.is_ms_shipped = 0 -- Exclude system tables
--GROUP BY sch.name, t.name, i.name, ps.name, pf.name, p.partition_number, fg.name
--ORDER BY SchemaName, TableName, p.partition_number;




SELECT 
    sch.name AS SchemaName,
    t.name AS TableName,
    i.name AS IndexName,
    ps.name AS PartitionScheme,
    pf.name AS PartitionFunction,
    COUNT(DISTINCT p.partition_number) AS NumberOfPartitions
FROM sys.tables t
JOIN sys.schemas sch ON t.schema_id = sch.schema_id
JOIN sys.indexes i ON t.object_id = i.object_id
JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
WHERE i.type IN (1, 5) -- Clustered indexes (1) and Clustered Columnstore Indexes (5)
AND t.is_ms_shipped = 0 -- Exclude system tables
GROUP BY sch.name, t.name, i.name, ps.name, pf.name
ORDER BY SchemaName, TableName;


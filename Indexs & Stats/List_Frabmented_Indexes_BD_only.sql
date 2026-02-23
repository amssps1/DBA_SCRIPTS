SELECT
  db_name() AS dbname, s.name AS schema_name, o.name AS table_name, i.name AS index_name,
  ips.index_type_desc, ips.avg_fragmentation_in_percent, ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') ips
JOIN sys.indexes i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
JOIN sys.objects o ON o.object_id = i.object_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE i.index_id > 0 AND ips.page_count >= 1000  -- ignora índices pequenos
ORDER BY ips.avg_fragmentation_in_percent DESC;

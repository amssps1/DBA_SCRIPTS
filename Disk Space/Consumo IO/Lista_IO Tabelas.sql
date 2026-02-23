SELECT 
    OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
    OBJECT_NAME(i.object_id) AS TableName,
    SUM(us.user_seeks + us.user_scans + us.user_lookups) AS TotalReads,
    SUM(us.user_updates) AS TotalWrites,
    (SUM(us.user_seeks + us.user_scans + us.user_lookups) + SUM(us.user_updates)) AS TotalIO
FROM 
    sys.dm_db_index_usage_stats AS us
INNER JOIN 
    sys.indexes AS i ON us.object_id = i.object_id AND us.index_id = i.index_id
WHERE 
    us.database_id = DB_ID()  -- Current database
GROUP BY 
    OBJECT_SCHEMA_NAME(i.object_id), 
    OBJECT_NAME(i.object_id)
ORDER BY 
    TotalIO DESC;

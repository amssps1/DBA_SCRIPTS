/* ==============================================
   Verificar fragmentação de uma tabela e índices
   ============================================== */
DECLARE 
    @SchemaName sysname = N'dbo',       
    @TableName  sysname = N'dossier'; 

DECLARE @ObjectId int = OBJECT_ID(QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName));

IF @ObjectId IS NULL
BEGIN
    RAISERROR('Tabela %s.%s não encontrada.', 16, 1, @SchemaName, @TableName);
    RETURN;
END;

SELECT 
    DB_NAME()                          AS DatabaseName,
    OBJECT_SCHEMA_NAME(ips.object_id)  AS SchemaName,
    OBJECT_NAME(ips.object_id)         AS TableName,
    i.index_id,
    i.name                             AS IndexName,
    i.type_desc                        AS IndexType,
    ips.index_type_desc,
    ips.alloc_unit_type_desc,
    ips.partition_number,
    ips.page_count,
    ips.record_count,
    ips.avg_fragmentation_in_percent,
    ips.avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats
       (DB_ID(), @ObjectId, NULL, NULL, 'SAMPLED') AS ips
JOIN sys.indexes AS i
     ON ips.object_id = i.object_id
    AND ips.index_id = i.index_id
WHERE i.index_id > 0              -- exclui heap (index_id = 0), se quiseres inclui
ORDER BY ips.avg_fragmentation_in_percent DESC;

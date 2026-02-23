-- CCIX
USE [IDH]
GO

ALTER INDEX [CCIX_RSK_LogODM] ON [dbo].[RSK_LogODM] REORGANIZE WITH (COMPRESS_ALL_ROW_GROUPS = ON);

ALTER INDEX [CCIX_RSK_LogODM] ON [dbo].[RSK_LogODM]  REBUILD WITH (ONLINE = ON);

--------------------------- 
-- Ver todos os grupos

-- Filtra por uma tabela específica (ajusta)
DECLARE @TargetObjectId int = OBJECT_ID(N'dbo.RSK_LogODM');

SELECT
    s.name  AS schema_name,
    t.name  AS table_name,
    i.name  AS index_name,
    i.type_desc AS index_type_desc,            -- CLUSTERED/NONCLUSTERED COLUMNSTORE
    rg.partition_number,
    rg.row_group_id,
    rg.state_desc,                             -- OPEN / CLOSED / COMPRESSED / TOMBSTONE
    rg.total_rows,
    rg.deleted_rows,
    CAST(100.0 * rg.deleted_rows / NULLIF(rg.total_rows,0) AS decimal(5,2)) AS deleted_rows_pct,
    CAST(rg.size_in_bytes/1048576.0 AS decimal(18,2)) AS size_mb
FROM sys.dm_db_column_store_row_group_physical_stats AS rg
JOIN sys.partitions p
   ON p.object_id = rg.object_id
  AND p.index_id  = rg.index_id
  AND p.partition_number = rg.partition_number      -- << corrige aqui
JOIN sys.indexes i
   ON i.object_id = p.object_id AND i.index_id = p.index_id
JOIN sys.tables t
   ON t.object_id = i.object_id
JOIN sys.schemas s
   ON s.schema_id = t.schema_id
WHERE (@TargetObjectId IS NULL OR t.object_id = @TargetObjectId)
ORDER BY schema_name, table_name, index_name, rg.partition_number, rg.row_group_id;



---------------------------


WITH columnstore_row_group_partition
AS (SELECT object_id,
           index_id,
           partition_number,
           SUM(deleted_rows) AS partition_deleted_rows,
           SUM(total_rows) AS partition_total_rows
    FROM sys.dm_db_column_store_row_group_physical_stats
    WHERE state_desc = 'COMPRESSED'
    GROUP BY object_id, index_id, partition_number),
/* For nonclustered columnstore, include rows in the delete buffer */
 columnstore_internal_partition
AS (SELECT object_id,
           index_id,
           partition_number,
           SUM(rows) AS delete_buffer_rows
    FROM sys.internal_partitions
    WHERE internal_object_type_desc = 'COLUMN_STORE_DELETE_BUFFER'
    GROUP BY object_id, index_id, partition_number)
SELECT OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
       OBJECT_NAME(i.object_id) AS object_name,
       i.name AS index_name,
       i.type_desc AS index_type,
       crgp.partition_number,
       100.0 * (ISNULL(crgp.partition_deleted_rows + ISNULL(cip.delete_buffer_rows, 0), 0)) / NULLIF (crgp.partition_total_rows, 0) AS avg_fragmentation_in_percent
FROM sys.indexes AS i
     INNER JOIN columnstore_row_group_partition AS crgp
         ON i.object_id = crgp.object_id
        AND i.index_id = crgp.index_id
     LEFT OUTER JOIN columnstore_internal_partition AS cip
         ON i.object_id = cip.object_id
        AND i.index_id = cip.index_id
        AND crgp.partition_number = cip.partition_number
ORDER BY schema_name, object_name, index_name, partition_number, index_type;

-- CCIX ver os row groups

DECLARE @TargetObjectId int = OBJECT_ID(N'dbo.RSK_LogODM');

;WITH RG AS (
    SELECT
        rg.object_id, rg.index_id,
        SUM(CASE WHEN rg.state_desc='COMPRESSED' THEN 1 ELSE 0 END) AS compressed_rg,
        SUM(CASE WHEN rg.state_desc='OPEN'       THEN 1 ELSE 0 END) AS open_rg,
        SUM(CASE WHEN rg.state_desc='CLOSED'     THEN 1 ELSE 0 END) AS closed_rg,
        SUM(CASE WHEN rg.state_desc='TOMBSTONE'  THEN 1 ELSE 0 END) AS tombstone_rg,
        SUM(rg.total_rows)   AS total_rows,
        SUM(rg.deleted_rows) AS deleted_rows
    FROM sys.dm_db_column_store_row_group_physical_stats rg
    GROUP BY rg.object_id, rg.index_id
)
SELECT
  s.name AS schema_name, t.name AS table_name,
  i.name AS index_name, i.type_desc,
  RG.compressed_rg, RG.open_rg, RG.closed_rg, RG.tombstone_rg,
  RG.total_rows, RG.deleted_rows,
  CAST(100.0 * RG.deleted_rows / NULLIF(RG.total_rows,0) AS decimal(5,2)) AS deleted_rows_pct,
  CASE
    WHEN RG.total_rows = 0 THEN 'Sem dados'
    WHEN 100.0 * RG.deleted_rows / NULLIF(RG.total_rows,0) >= 30 THEN 'REBUILD'
    WHEN RG.open_rg > 0 OR RG.closed_rg > 0 THEN 'REORGANIZE (COMPRESS_ALL_ROW_GROUPS = ON)'
    WHEN 100.0 * RG.deleted_rows / NULLIF(RG.total_rows,0) BETWEEN 10 AND 30 THEN 'REORGANIZE (avaliar REBUILD)'
    ELSE 'OK'
  END AS recomendacao
FROM RG
JOIN sys.indexes i ON i.object_id=RG.object_id AND i.index_id=RG.index_id
JOIN sys.tables  t ON t.object_id=i.object_id
JOIN sys.schemas s ON s.schema_id=t.schema_id
WHERE (@TargetObjectId IS NULL OR t.object_id = @TargetObjectId)
  AND i.type IN (5,6)  -- 5=CCI, 6=NCCI
ORDER BY deleted_rows_pct DESC, schema_name, table_name;

 

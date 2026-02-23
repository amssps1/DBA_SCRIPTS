DECLARE @FilegroupName sysname = N'PRIMARY';  -- <- muda aqui (ou põe NULL para todos)

/* -----------------------------------------------------------
   DETALHE: Tabelas/Índices por Filegroup (inclui particionadas)
   ----------------------------------------------------------- */
;WITH AU AS (
    SELECT
        s.name  AS schema_name,
        t.name  AS table_name,
        i.name  AS index_name,
        i.index_id,
        i.type_desc AS index_type_desc,
        p.partition_number,
        au.type_desc AS alloc_unit_type,         -- IN_ROW_DATA / LOB_DATA / ROW_OVERFLOW_DATA
        au.total_pages,
        au.used_pages,
        au.data_pages,
        -- Resolver o filegroup real: direto (FG) ou via Partition Scheme
        fg_direct.name AS fg_name_direct,
        fg_from_ps.name AS fg_name_from_ps,
        COALESCE(fg_from_ps.name, fg_direct.name) AS resolved_filegroup
    FROM sys.tables t
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    JOIN sys.indexes i ON i.object_id = t.object_id           -- inclui HEAP (index_id = 0)
    JOIN sys.partitions p
         ON p.object_id = i.object_id AND p.index_id = i.index_id
    JOIN sys.allocation_units au
         ON au.container_id IN (p.hobt_id, p.partition_id)
    -- Espaço de dados do índice (pode ser FG direto ou Partition Scheme)
    JOIN sys.data_spaces ds
         ON ds.data_space_id = i.data_space_id
    -- Se for filegroup direto:
    LEFT JOIN sys.filegroups fg_direct
         ON fg_direct.data_space_id = i.data_space_id
    -- Se for partition scheme: mapear partition_number -> filegroup
    LEFT JOIN sys.partition_schemes ps
         ON ps.data_space_id = i.data_space_id
    LEFT JOIN sys.destination_data_spaces dds
         ON dds.partition_scheme_id = ps.data_space_id
        AND dds.destination_id      = p.partition_number
    LEFT JOIN sys.filegroups fg_from_ps
         ON fg_from_ps.data_space_id = dds.data_space_id
)
SELECT
    schema_name,
    table_name,
    COALESCE(index_name, '<<HEAP>>') AS index_name,
    CASE
        WHEN index_id = 0 THEN 'TABLE (HEAP)'
        ELSE 'INDEX (' + index_type_desc + ')'
    END AS ObjectType,
    resolved_filegroup AS filegroup_name,
    alloc_unit_type,
    partition_number,
    SUM(data_pages)  * 8.0 / 1024 AS data_MB,
    SUM(used_pages)  * 8.0 / 1024 AS used_MB,
    SUM(total_pages) * 8.0 / 1024 AS reserved_MB
FROM AU
WHERE (@FilegroupName IS NULL OR resolved_filegroup = @FilegroupName)
GROUP BY
    schema_name, table_name, COALESCE(index_name, '<<HEAP>>'),
    CASE WHEN index_id = 0 THEN 'TABLE (HEAP)'
         ELSE 'INDEX (' + index_type_desc + ')' END,
    resolved_filegroup, alloc_unit_type, partition_number
ORDER BY
 --   filegroup_name, schema_name, table_name, ObjectType, index_name, alloc_unit_type, partition_number;
 data_mb desc;






--USE [IDH];
--IF EXISTS (SELECT 1 FROM sys.filegroups WHERE name = N'IDH_Data_P21')
--BEGIN
--    ALTER DATABASE [IDH] MODIFY FILEGROUP [IDH_Data_P21] DEFAULT;
--END
--ELSE
--BEGIN
--    RAISERROR('Filegroup IDH_Data_P2 não existe em IDH.', 16, 1);
--END



--USE [master];
---- 1) Criar o filegroup
--ALTER DATABASE [IDH] ADD FILEGROUP [IDH_Data_P21];

--ALTER DATABASE [IDH]
--ADD FILE (
--    NAME = N'IDH_Data_P21',
--    FILENAME = N'E:\DATA\IDH_Data_P21.ndf',  -- <<<<< ajusta o caminho
--    SIZE = 1024MB,
--    FILEGROWTH = 512MB
--) TO FILEGROUP [IDH_Data_P21];



--USE [IDH];          -- <<< troque para a sua BD
--GO
--ALTER DATABASE [IDH]
--    MODIFY FILEGROUP [IDH_Data_P21] DEFAULT;   -- <<< nome do filegroup
--GO

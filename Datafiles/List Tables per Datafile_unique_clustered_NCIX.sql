DECLARE @FilegroupName sysname = N'PRIMARY';  -- <- muda aqui (ou põe NULL para todos)
--DECLARE @FilegroupName sysname = N'IDH_Data_P21';

;WITH AU AS (
    SELECT
        s.name  AS schema_name,
        t.name  AS table_name,
        i.object_id,
        i.name  AS index_name,
        i.index_id,
        i.type_desc AS index_type_desc,
        i.is_unique,                                  -- << NOVO
        p.partition_number,
        au.type_desc AS alloc_unit_type,              -- IN_ROW_DATA / LOB_DATA / ROW_OVERFLOW_DATA
        au.total_pages,
        au.used_pages,
        au.data_pages,
        -- Resolver o filegroup real: direto (FG) ou via Partition Scheme
        fg_direct.name   AS fg_name_direct,
        fg_from_ps.name  AS fg_name_from_ps,
        COALESCE(fg_from_ps.name, fg_direct.name) AS resolved_filegroup
    FROM sys.tables t
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    JOIN sys.indexes i ON i.object_id = t.object_id           -- inclui HEAP (index_id = 0)
    JOIN sys.partitions p
         ON p.object_id = i.object_id AND p.index_id = i.index_id
    JOIN sys.allocation_units au
         ON au.container_id IN (p.hobt_id, p.partition_id)
    JOIN sys.data_spaces ds
         ON ds.data_space_id = i.data_space_id
    LEFT JOIN sys.filegroups fg_direct
         ON fg_direct.data_space_id = i.data_space_id
    LEFT JOIN sys.partition_schemes ps
         ON ps.data_space_id = i.data_space_id
    LEFT JOIN sys.destination_data_spaces dds
         ON dds.partition_scheme_id = ps.data_space_id
        AND dds.destination_id      = p.partition_number
    LEFT JOIN sys.filegroups fg_from_ps
         ON fg_from_ps.data_space_id = dds.data_space_id
),
IDXDEF AS (  -- definição de colunas por índice (key + include)
    SELECT
        i.object_id,
        i.index_id,
        KeyCols =
            STUFF((
                SELECT ', ' + QUOTENAME(c.name) +
                       CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE '' END
                FROM sys.index_columns ic
                JOIN sys.columns c
                  ON c.object_id = ic.object_id
                 AND c.column_id = ic.column_id
                WHERE ic.object_id = i.object_id
                  AND ic.index_id  = i.index_id
                  AND ic.is_included_column = 0
                ORDER BY ic.key_ordinal
                FOR XML PATH(''), TYPE
            ).value('.','nvarchar(max)'),1,2,''),
        IncludeCols =
            STUFF((
                SELECT ', ' + QUOTENAME(c.name)
                FROM sys.index_columns ic
                JOIN sys.columns c
                  ON c.object_id = ic.object_id
                 AND c.column_id = ic.column_id
                WHERE ic.object_id = i.object_id
                  AND ic.index_id  = i.index_id
                  AND ic.is_included_column = 1
                ORDER BY c.name
                FOR XML PATH(''), TYPE
            ).value('.','nvarchar(max)'),1,2,'')
    FROM sys.indexes i
)
SELECT
    schema_name,
    table_name,
    COALESCE(index_name, '<<HEAP>>') AS index_name,

    /* -------- ObjectType com UNIQUE/NONUNIQUE para clustered -------- */
    CASE
        WHEN AU.index_id = 0 THEN 'TABLE (HEAP)'
        WHEN AU.index_type_desc LIKE 'CLUSTERED%' THEN
            'INDEX (' + AU.index_type_desc + ', ' + CASE WHEN AU.is_unique = 1 THEN 'UNIQUE' ELSE 'NONUNIQUE' END + ')'
        ELSE
            'INDEX (' + AU.index_type_desc + ')'
    END AS ObjectType,

    /* Colunas do índice (keys + INCLUDE) */
    CASE 
        WHEN AU.index_id = 0 THEN NULL
        ELSE
            CASE WHEN D.KeyCols IS NULL OR D.KeyCols = '' THEN '(no key columns?)' ELSE D.KeyCols END +
            CASE WHEN D.IncludeCols IS NOT NULL AND D.IncludeCols <> ''
                 THEN ' INCLUDE (' + D.IncludeCols + ')'
                 ELSE ''
            END
    END AS index_columns,

    AU.resolved_filegroup AS filegroup_name,
    AU.alloc_unit_type,
    AU.partition_number,
    SUM(AU.data_pages)  * 8.0 / 1024 AS data_MB,
    SUM(AU.used_pages)  * 8.0 / 1024 AS used_MB,
    SUM(AU.total_pages) * 8.0 / 1024 AS reserved_MB
FROM AU
LEFT JOIN IDXDEF D
       ON D.object_id = AU.object_id
      AND D.index_id  = AU.index_id
WHERE (@FilegroupName IS NULL OR AU.resolved_filegroup = @FilegroupName)
GROUP BY
    schema_name,
    table_name,
    COALESCE(index_name, '<<HEAP>>'),
    AU.index_id,
    AU.index_type_desc,
    AU.is_unique,                                 -- << garantir consistência do ObjectType
    /* mesma expressão de index_columns usada acima */
    CASE 
        WHEN AU.index_id = 0 THEN NULL
        ELSE
            CASE WHEN D.KeyCols IS NULL OR D.KeyCols = '' THEN '(no key columns?)' ELSE D.KeyCols END +
            CASE WHEN D.IncludeCols IS NOT NULL AND D.IncludeCols <> ''
                 THEN ' INCLUDE (' + D.IncludeCols + ')'
                 ELSE ''
            END
    END,
    AU.resolved_filegroup,
    AU.alloc_unit_type,
    AU.partition_number
ORDER BY
    data_MB DESC;

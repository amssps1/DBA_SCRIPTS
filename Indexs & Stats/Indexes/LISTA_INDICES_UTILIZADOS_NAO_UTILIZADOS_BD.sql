/* ================================================================
   RELATÓRIO COMPLETO DE ÍNDICES (USADOS E NÃO USADOS)
   - Mostra índices usados primeiro
   - Depois os índices não utilizados
   - Ordenado por Schema → Tabela → Tipo (Usado / Não usado)
   ================================================================ */

WITH IndexInfo AS 
(
    SELECT
        DB_NAME() AS DatabaseName,
        SCHEMA_NAME(o.schema_id) AS SchemaName,
        o.name AS TableName,
        i.index_id,
        i.name AS IndexName,
        i.type_desc AS IndexType,
        i.is_primary_key,
        i.is_unique,
        i.is_unique_constraint,
        us.user_seeks,
        us.user_scans,
        us.user_lookups,
        us.user_updates,
        TotalReads = ISNULL(us.user_seeks,0) + ISNULL(us.user_scans,0) + ISNULL(us.user_lookups,0),
        UsageCategory =
            CASE 
                WHEN us.user_seeks IS NULL AND us.user_scans IS NULL AND us.user_lookups IS NULL
                    THEN 'NÃO UTILIZADO'
                ELSE 'UTILIZADO'
            END
    FROM sys.indexes i
    INNER JOIN sys.objects o 
            ON i.object_id = o.object_id
    LEFT JOIN sys.dm_db_index_usage_stats us
            ON i.object_id = us.object_id
           AND i.index_id = us.index_id
           AND us.database_id = DB_ID()
    WHERE 
        o.type = 'U'  -- apenas tabelas de utilizador
        AND i.index_id > 0 -- excluir heaps
)
SELECT *
FROM IndexInfo
ORDER BY 
    SchemaName,
    TableName,
    CASE WHEN UsageCategory = 'UTILIZADO' THEN 0 ELSE 1 END,   -- usados primeiro
    TotalReads DESC;

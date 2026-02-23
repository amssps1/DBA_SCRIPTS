WITH IndexColumns AS
(
    SELECT I.object_id AS TableObjectId, OBJECT_SCHEMA_NAME(I.object_id) + '.' + OBJECT_NAME(I.object_id) AS TableName, I.index_id AS IndexId, I.name AS IndexName
        , (IndexUsage.user_seeks + IndexUsage.user_scans + IndexUsage.user_lookups) AS IndexUsage
        , IndexUsage.user_updates AS IndexUpdates

       , (SELECT CASE is_included_column WHEN 1 THEN NULL ELSE column_id END AS [data()]
        FROM sys.index_columns AS IndexColumns
        WHERE IndexColumns.object_id = I.object_id
          AND IndexColumns.index_id = I.index_id
        ORDER BY index_column_id, column_id
        FOR XML PATH('')
       ) AS ConcIndexColumnNrs

       ,(SELECT CASE is_included_column WHEN 1 THEN NULL ELSE COL_NAME(I.object_id, column_id) END AS [data()]
        FROM sys.index_columns AS IndexColumns
        WHERE IndexColumns.object_id = I.object_id
          AND IndexColumns.index_id = I.index_id
        ORDER BY index_column_id, column_id
        FOR XML PATH('')
       ) AS ConcIndexColumnNames

       ,(SELECT CASE is_included_column WHEN 1 THEN column_id ELSE NULL END AS [data()]
        FROM sys.index_columns AS IndexColumns
        WHERE IndexColumns.object_id = I.object_id
        AND IndexColumns.index_id = I.index_id
        ORDER BY column_id
        FOR XML PATH('')
       ) AS ConcIncludeColumnNrs

       ,(SELECT CASE is_included_column WHEN 1 THEN COL_NAME(I.object_id, column_id) ELSE NULL END AS [data()]
        FROM sys.index_columns AS IndexColumns
        WHERE IndexColumns.object_id = I.object_id
          AND IndexColumns.index_id = I.index_id
        ORDER BY column_id
        FOR XML PATH('')
       ) AS ConcIncludeColumnNames
    FROM sys.indexes AS I
       LEFT OUTER JOIN sys.dm_db_index_usage_stats AS IndexUsage
        ON IndexUsage.object_id = I.object_id
          AND IndexUsage.index_id = I.index_id
          AND IndexUsage.Database_id = db_id() 
)
SELECT
  C1.TableName
  , C1.IndexName AS 'Index1'
  , C2.IndexName AS 'Index2'
  , CASE WHEN (C1.ConcIndexColumnNrs = C2.ConcIndexColumnNrs) AND (C1.ConcIncludeColumnNrs = C2.ConcIncludeColumnNrs) THEN 'Exact duplicate'
        WHEN (C1.ConcIndexColumnNrs = C2.ConcIndexColumnNrs) THEN 'Different includes'
        ELSE 'Overlapping columns' END
--  , C1.ConcIndexColumnNrs
--  , C2.ConcIndexColumnNrs
  , C1.ConcIndexColumnNames as ConcIndexColumnNames1
  , C2.ConcIndexColumnNames as ConcIndexColumnNames2
--  , C1.ConcIncludeColumnNrs
--  , C2.ConcIncludeColumnNrs
  , C1.ConcIncludeColumnNames as ConcIncludeColumnNames1
  , C2.ConcIncludeColumnNames as ConcIncludeColumnNames2
  , C1.IndexUsage as IndexUsage1
  , C2.IndexUsage as IndexUsage2
  , C1.IndexUpdates as IndexUpdates1
  , C2.IndexUpdates as IndexUpdates2
  , 'DROP INDEX ' + C2.IndexName + ' ON ' + C2.TableName AS Drop2
  , 'DROP INDEX ' + C1.IndexName + ' ON ' + C1.TableName AS Drop1
FROM IndexColumns AS C1
  INNER JOIN IndexColumns AS C2 
    ON (C1.TableObjectId = C2.TableObjectId)
    AND (
         -- exact: show lower IndexId as 1
            (C1.IndexId < C2.IndexId
            AND C1.ConcIndexColumnNrs = C2.ConcIndexColumnNrs
            AND C1.ConcIncludeColumnNrs = C2.ConcIncludeColumnNrs)
         -- different includes: show longer include as 1
         OR (C1.ConcIndexColumnNrs = C2.ConcIndexColumnNrs
            AND LEN(C1.ConcIncludeColumnNrs) > LEN(C2.ConcIncludeColumnNrs))
         -- overlapping: show longer index as 1
         OR (C1.IndexId <> C2.IndexId
            AND C1.ConcIndexColumnNrs <> C2.ConcIndexColumnNrs
            AND C1.ConcIndexColumnNrs like C2.ConcIndexColumnNrs + ' %')
    )
ORDER BY C1.TableName, C1.ConcIndexColumnNrs
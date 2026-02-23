---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
-- Purpose: This query will list all indexes in the database and show index columns and included columns 
-- using STRING_AGG (SQL 2017 and later). Run this in the user database.
-- More Information: https://www.mssqltips.com/sqlservertip/2914/rolling-up-multiple-rows-into-a-single-row-and-column-for-sql-server-data/

SELECT 
   SCHEMA_NAME(ss.SCHEMA_id) AS SCHEMANAME,
   ss.name as TableName, 
   ss2.name as IndexName, 
   ss2.index_id,
   (SELECT STRING_AGG(name,', ') 
    from sys.index_columns a inner join sys.all_columns b on a.object_id = b.object_id and a.column_id = b.column_id and a.object_id = ss.object_id and a.index_id = ss2.index_id and is_included_column = 0
	) as IndexColumns,
   (SELECT STRING_AGG(name,', ') 
    from sys.index_columns a inner join sys.all_columns b on a.object_id = b.object_id and a.column_id = b.column_id and a.object_id = ss.object_id and a.index_id = ss2.index_id and is_included_column = 1
    ) as IncludedColumns
FROM sys.objects SS INNER JOIN SYS.INDEXES ss2 ON ss.OBJECT_ID = ss2.OBJECT_ID 
WHERE ss.type = 'U'
ORDER BY 1, 2, 3   
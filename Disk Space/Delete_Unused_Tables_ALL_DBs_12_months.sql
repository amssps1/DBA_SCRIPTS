
DECLARE @findKeySQL nvarchar(2000)
DECLARE @searchKey nvarchar(20)

SET @searchKey = lower('%remote%')

SET @findKeySQL = 'IF ''[?]'' NOT IN (''[master]'', ''[model]'', 
                                     ''[msdb]'', ''[tempdb]'')

			 with UnUsedTables (TableName , TotalRowCount, CreatedDate , LastModifiedDate ) 
			AS ( 
			  SELECT distinct DBTable.name AS TableName
				 ,PS.row_count AS TotalRowCount
				 ,DBTable.create_date AS CreatedDate
				 ,DBTable.modify_date AS LastModifiedDate
			  FROM sys.tables  DBTable 
				 JOIN sys.dm_db_partition_stats PS ON OBJECT_NAME(PS.object_id)=DBTable.name
			  WHERE DBTable.type =''U'' 
				 AND NOT EXISTS (SELECT OBJECT_ID  
								 FROM sys.dm_db_index_usage_stats
								 WHERE OBJECT_ID = DBTable.object_id )
			)
			-- Select data from the CTE
			SELECT ''?'' as DBName,TableName , TotalRowCount, CreatedDate , LastModifiedDate 
			FROM UnUsedTables
			where TableName not in (''spt_fallback_db'',''spt_fallback_dev'',''spt_fallback_usg'',''spt_monitor'',''MSreplication_options'') 
			and LastModifiedDate < DateAdd(YEAR,-1,GetDate())
			ORDER BY TotalRowCount ASC

'

EXEC sp_MSForEachDB @findKeySQL



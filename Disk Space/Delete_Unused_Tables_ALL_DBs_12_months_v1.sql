set nocount on

USE [master];
GO

if object_id('tempdb..#temp') is not null drop table #temp

CREATE TABLE #temp(
    rec_id      int IDENTITY (1, 1),
    db sysname, 
    TableName   varchar(128),
    SchemaName varchar(128),
    RowCounts   bigint,
	CreatedDate datetime,
	LastModifiedDate datetime,
    TotalSpaceMB    decimal(15,2)  
   )


exec sp_MSforeachdb 'USE [?]; 
insert into #temp (db, TableName, SchemaName,RowCounts,CreatedDate,LastModifiedDate,  TotalSpaceMB)
	SELECT  
	''?'' as db,    
	t.NAME AS TableName,    
	s.Name AS SchemaName,    
	p.rows AS RowCounts, 
	t.create_date AS CreatedDate,
	t.modify_date AS LastModifiedDate,
	SUM(a.total_pages) * 8/1024 AS TotalSpaceMB     

	FROM     sys.tables t 
	INNER JOIN      sys.indexes i ON t.OBJECT_ID = i.object_id
	INNER JOIN    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id 
	INNER JOIN     sys.allocation_units a ON p.partition_id = a.container_id
	LEFT OUTER JOIN     sys.schemas s ON t.schema_id = s.schema_id 
	WHERE    p.rows > 0 AND t.is_ms_shipped = 0    AND i.OBJECT_ID > 255 
	AND NOT EXISTS (SELECT OBJECT_ID  
								 FROM sys.dm_db_index_usage_stats
								 WHERE OBJECT_ID = t.object_id )
	GROUP BY     t.Name, s.Name, p.Rows ,t.create_date,t.modify_date
    ORDER BY p.rows DESC' ;

	

select db, TableName, SchemaName, RowCounts,CreatedDate,LastModifiedDate, TotalSpaceMB
from #temp
where 	db not in ('master','msdb','model','tempdb','dba_db','SSISDB')
and  TableName not in ('spt_fallback_db','spt_fallback_dev','spt_fallback_usg','spt_monitor','MSreplication_options') 
			and LastModifiedDate < DateAdd(YEAR,-1,GetDate())
			ORDER BY 1,2 ASC

drop table if exists #temp
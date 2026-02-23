;With cte_backup AS (

SELECT 
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
   msdb.dbo.backupset.database_name, 
   msdb.dbo.backupset.backup_start_date, 
   msdb.dbo.backupset.backup_finish_date as Data_Backup, 
   CASE msdb..backupset.type 
      WHEN 'D' THEN 'Database' 
      WHEN 'Í' THEN 'Differencial' 
      WHEN 'F' THEN 'Filegroup' 
      WHEN 'P' THEN 'Partial' 
      WHEN 'G' THEN 'Differencial File' 
	  WHEN 'L' THEN 'Log' 
      END AS backup_type, 
--   (msdb.dbo.backupset.backup_size) as tamanho, 

   ROW_NUMBER() OVER (    PARTITION BY msdb.dbo.backupset.backup_size  ORDER BY msdb.dbo.backupset.backup_finish_date DESC) AS RowNumber,

   CAST(msdb.dbo.backupset.backup_size / (1024 * 1024 * 1024) AS DECIMAL(6,2)) AS [Total (GB)],


   msdb.dbo.backupmediafamily.logical_device_name, 
   msdb.dbo.backupmediafamily.physical_device_name, 
   msdb.dbo.backupset.name AS backupset_name, 
   msdb.dbo.backupset.description 
FROM 
   msdb.dbo.backupmediafamily 
   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
WHERE 
   (CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 15) and database_name not in ('master','model','tempdb','msdb')
   and database_name ='ODMDC'


)

select * from cte_backup 
where RowNumber = 1
order by Data_Backup desc



SELECT sqlserver_start_time 
FROM sys.dm_os_sys_info;


  declare @SystemStartDate datetime
set @SystemStartDate =(select create_date from sys.databases where name='TempDB')

PRINT @SystemStartDate

BACKUP DATABASE Hangfire
TO DISK = 'Y:\BACKUP\Hangfire.bak'
WITH INIT
Go
 
--Run Log Backup
BACKUP Log Hangfire
TO DISK = 'Y:\BACKUP\Hangfire_log.trn'
WITH INIT



----
-- EOS
--RESTORE Full Backup
RESTORE DATABASE Hangfire
FROM DISK = 'Y:\BACKUP\Hangfire.bak' 
 WITH NORECOVERY,
 MOVE 'Hangfire' TO 'Y:\DATA\Hangfire.mdf',
 MOVE 'Hangfire_log' TO 'L:\Log\Hangfirex_log.ldf'
 GO
 
--RESTORE TLog Backup
RESTORE DATABASE Hangfire
FROM DISK = 'Y:\BACKUP\Hangfire_log.trn' 
 WITH NORECOVERY
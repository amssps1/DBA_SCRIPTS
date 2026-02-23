BACKUP DATABASE Paybylink
TO DISK = 'E:\BACKUP\Paybylink.bak'
WITH INIT
Go
 
--Run Log Backup
BACKUP Log Paybylink
TO DISK = 'E:\BACKUP\Paybylink_log.trn'
WITH INIT


----
-- Priapo
--RESTORE Full Backup
RESTORE DATABASE Paybylink
FROM DISK = 'E:\BACKUP\Paybylink.bak' 
 WITH NORECOVERY,
 MOVE 'Paybylink' TO 'E:\DATA\Paybylink.mdf',
 MOVE 'Paybylink_log' TO 'L:\Log\Paybylink_log.ldf'
 GO
 
--RESTORE TLog Backup
RESTORE DATABASE Paybylink
FROM DISK = 'E:\BACKUP\Paybylink_log.trn' 
 WITH NORECOVERY
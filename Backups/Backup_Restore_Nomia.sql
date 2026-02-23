BACKUP DATABASE Nomia
TO DISK = 'E:\BACKUP\Nomia.bak'
WITH INIT
Go
 
--Run Log Backup
BACKUP Log Nomia
TO DISK = 'E:\BACKUP\Nomia_log.trn'
WITH INIT



----
-- Priapo
--RESTORE Full Backup
RESTORE DATABASE Nomia
FROM DISK = 'E:\BACKUP\Nomia.bak' 
 WITH NORECOVERY,
 MOVE 'Nomia' TO 'E:\DATA\Nomia.mdf',
 MOVE 'Nomia_log' TO 'L:\Log\Nomiax_log.ldf'
 GO
 
--RESTORE TLog Backup
RESTORE DATABASE Nomia
FROM DISK = 'E:\BACKUP\Nomia_log.trn' 
 WITH NORECOVERY
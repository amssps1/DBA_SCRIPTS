BACKUP DATABASE QualContactCenter360
TO DISK = 'E:\BACKUP\QualContactCenter360.bak'
WITH INIT,compression, stats=5
Go
 
--Run Log Backup
BACKUP Log QualContactCenter360
TO DISK = 'E:\BACKUP\QualContactCenter360_log.trn'
WITH INIT



----
-- Priapo
--RESTORE Full Backup
RESTORE DATABASE ContactCenter360_TESTE
FROM DISK = 'E:\BACKUP\QualContactCenter360.bak' 
 WITH RECOVERY,
 MOVE 'Nomia' TO 'E:\DATA\QualContactCenter360.mdf',
 MOVE 'Nomia_log' TO 'L:\Log\QualContactCenter360_log.ldf'
 GO
/* 
--RESTORE TLog Backup
RESTORE DATABASE Nomia
FROM DISK = 'E:\BACKUP\Nomia_log.trn' 
 WITH NORECOVERY
 */
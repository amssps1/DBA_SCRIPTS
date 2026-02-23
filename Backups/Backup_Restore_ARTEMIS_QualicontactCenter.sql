BACKUP DATABASE QualContactCenter360
TO DISK = 'H:\c360\QualContactCenter360.bak'
WITH INIT
Go
 
--Run Log Backup
BACKUP Log QualContactCenter360
TO DISK = 'H:\c360\QualContactCenter360_log.trn'
WITH INIT



----
-- EOS
--RESTORE Full Backup
RESTORE DATABASE QualContactCenter360
FROM DISK = 'E:\BACKUP\QualContactCenter360.bak'
 WITH NORECOVERY,
 MOVE 'QualContactCenter360' TO 'E:\DATA\QualContactCenter360.mdf',
 MOVE 'QualContactCenter360_log' TO 'L:\Log\QualContactCenter360_log.ldf'
 GO
 
--RESTORE TLog Backup
RESTORE DATABASE QualContactCenter360
FROM DISK = 'E:\BACKUP\QualContactCenter360_log.trn'
 WITH NORECOVERY
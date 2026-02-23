BACKUP DATABASE RskDecisao
TO DISK = 'Y:\BACKUP\RskDecisao.bak'
WITH INIT
Go
 
--Run Log Backup
BACKUP Log RskDecisao
TO DISK = 'Y:\BACKUP\RskDecisao_log.trn'
WITH INIT



----
-- EOS
--RESTORE Full Backup
RESTORE DATABASE RskDecisao
FROM DISK = 'Y:\BACKUP\RskDecisao.bak' 
 WITH NORECOVERY,
 MOVE 'RskDecisao' TO 'Y:\DATA\RskDecisao.mdf',
 MOVE 'RskDecisao_log' TO 'L:\Log\RskDecisaox_log.ldf'
 GO
 
--RESTORE TLog Backup
RESTORE DATABASE RskDecisao
FROM DISK = 'Y:\BACKUP\RskDecisao_log.trn' 
 WITH NORECOVERY
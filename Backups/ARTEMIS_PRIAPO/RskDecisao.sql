BACKUP DATABASE RskDecisao
TO DISK = 'E:\BACKUP\RskDecisao.bak'
WITH INIT
Go
 
--Run Log Backup
BACKUP Log RskDecisao
TO DISK = 'E:\BACKUP\RskDecisao_log.trn'
WITH INIT


--

----
-- Priapo
--RESTORE Full Backup
RESTORE DATABASE RskDecisao
FROM DISK = 'E:\BACKUP\RskDecisao.bak' 
 WITH NORECOVERY,
 MOVE 'RskDecisao' TO 'E:\DATA\RskDecisao.mdf',
 MOVE 'RskDecisao_log' TO 'L:\Log\RskDecisaox_log.ldf'
 GO
 
--RESTORE TLog Backup
RESTORE DATABASE RskDecisao
FROM DISK = 'E:\BACKUP\RskDecisao_log.trn' 
 WITH NORECOVERY

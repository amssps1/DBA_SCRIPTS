BACKUP DATABASE Interfacesdah
TO DISK = 'Y:\BACKUP\Interfacesdah.bak'
WITH INIT,stats=10
Go
 
--Run Log Backup
BACKUP Log Interfacesdah
TO DISK = 'Y:\BACKUP\Interfacesdah_log.trn'
WITH INIT



---

--RESTORE Full Backup
RESTORE DATABASE Interfacesdah
FROM DISK = 'E:\BACKUP\Interfacesdah.bak' 
 WITH NORECOVERY,stats=10,
 MOVE 'Interfacesdah' TO 'E:\DATA\Interfacesdah.mdf',
 MOVE 'Interfacesdah_log' TO 'L:\Log\Interfacesdah_log.ldf'
 GO
 
--RESTORE TLog Backup
RESTORE DATABASE Interfacesdah
FROM DISK = 'E:\BACKUPInterfacesdah_log.trn' 
 WITH NORECOVERY
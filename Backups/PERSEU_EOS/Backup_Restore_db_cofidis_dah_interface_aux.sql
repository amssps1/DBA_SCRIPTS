

USE [master]

BACKUP DATABASE db_cofidis_dah_interface_aux TO DISK = N'Y:\BACKUP\db_cofidis_dah_interface_aux.bak'
WITH INIT, COMPRESSION,  STATS = 10
Go
BACKUP LOG db_cofidis_dah_interface_aux TO DISK = N'Y:\BACKUP\db_cofidis_dah_interface_aux.trn'
WITH INIT
Go


---

USE master

GO

ALTER AVAILABILITY GROUP AG

ADD DATABASE db_cofidis_dah_interface_aux

GO





USE [master]

RESTORE DATABASE [db_cofidis_dah_interface_aux] FROM  DISK = N'Y:\BACKUP\db_cofidis_dah_interface_aux.bak' WITH  FILE = 1, 
	MOVE N'db_cofidis_dah_interface_FR' TO N'E:\DATA\db_cofidis_dah_interface_FR.mdf',  
	MOVE N'db_cofidis_dah_interface_FR_INDX' TO N'E:\DATA\db_cofidis_dah_interface_FR_INDX.ndf',  
		MOVE N'db_cofidis_dah_interface_FR_2' TO N'E:\DATA\db_cofidis_dah_interface_FR_2.ndf',  
			MOVE N'db_cofidis_dah_interface_FR_1' TO N'E:\DATA\db_cofidis_dah_interface_FR_1.ndf',  
	MOVE N'db_cofidis_dah_interface_FR_log' TO N'L:\log\db_cofidis_dah_interface_FR_log.ldf',   NORECOVERY, NOUNLOAD,  STATS = 5
GO
---- RESTORE LOG ----

RESTORE LOG [db_cofidis_dah_interface_aux] FROM  DISK = N'Y:\BACKUP\db_cofidis_dah_interface_aux.trn' WITH  NORECOVERY,FILE = 1,  NOUNLOAD,  STATS = 5
GO

-- No primario
ALTER AVAILABILITY GROUP [AG] ADD DATABASE [db_cofidis_dah_interface_aux];
/*On Secondary Node*/
ALTER DATABASE [db_cofidis_dah_interface_aux] SET HADR AVAILABILITY GROUP = [AG];



USE [master]

BACKUP DATABASE db_cofidis_dah_interface TO DISK = N'Y:\backup\db_cofidis_dah_interface.bak'
WITH INIT, COMPRESSION,  STATS = 10
Go
BACKUP LOG db_cofidis_dah_interface TO DISK = N'Y:\backup\db_cofidis_dah_interface.trn'
WITH INIT
Go


---

USE master

GO

ALTER AVAILABILITY GROUP AG

ADD DATABASE FactCofidis

GO





USE [master]

RESTORE DATABASE [FactCofidis] FROM  DISK = N'Y:\backup\FactCofidis.bak' WITH  FILE = 1, 
	MOVE N'FactCofidis' TO N'Y:\DATA\FactCofidis.mdf',  
		MOVE N'FactCofidis_idx' TO N'Y:\DATA\FactCofidis_idx.mdf',  
	
	MOVE N'FactCofidis_log' TO N'Y:\log\FactCofidis_Log.ldf',   NORECOVERY, NOUNLOAD,  STATS = 5
GO
---- RESTORE LOG ----

RESTORE LOG [db_cofidis_dah] FROM  DISK = N'Y:\backup\FactCofidis.trn' WITH  NORECOVERY,FILE = 1,  NOUNLOAD,  STATS = 5
GO

-- No primario
ALTER AVAILABILITY GROUP [AG] ADD DATABASE [FactCofidis];
/*On Secondary Node*/
ALTER DATABASE [FactCofidis] SET HADR AVAILABILITY GROUP = [AG];

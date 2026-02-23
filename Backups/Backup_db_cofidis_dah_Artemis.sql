

USE [master]

BACKUP DATABASE db_cofidis_dah TO DISK = N'E:\backup\db_cofidis_dah.bak'
WITH INIT, COMPRESSION,  STATS = 10
Go
BACKUP LOG db_cofidis_dah TO DISK = N'E:\backup\db_cofidis_dah.trn'
WITH INIT
Go


---

USE master

GO

ALTER AVAILABILITY GROUP AG

ADD DATABASE db_cofidis_dah

GO





USE [master]

RESTORE DATABASE [db_cofidis_dah] FROM  DISK = N'E:\backup\db_cofidis_dah.bak' WITH  FILE = 1, 
	MOVE N'db_cofidis_dah' TO N'E:\DATA\db_cofidis_dah.mdf',  

	MOVE N'db_cofidis_dah_log' TO N'L:\log\CofidisPayCore_Log.ldf',   NORECOVERY, NOUNLOAD,  STATS = 5
GO
---- RESTORE LOG ----

RESTORE LOG [db_cofidis_dah] FROM  DISK = N'E:\backup\db_cofidis_dah.trn' WITH  NORECOVERY,FILE = 1,  NOUNLOAD,  STATS = 5
GO

-- No primario
ALTER AVAILABILITY GROUP [AG] ADD DATABASE [db_cofidis_dah];
/*On Secondary Node*/
ALTER DATABASE [db_cofidis_dahe] SET HADR AVAILABILITY GROUP = [AG];

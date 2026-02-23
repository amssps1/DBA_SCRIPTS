

USE [master]

BACKUP DATABASE CofidisPayCore TO DISK = N'E:\backup\CofidisPayCore.bak'
WITH INIT, COMPRESSION,  STATS = 10
Go
BACKUP LOG CofidisPayCore TO DISK = N'E:\backup\CofidisPayCore.trn'
WITH INIT
Go


---

USE master

GO

ALTER AVAILABILITY GROUP AG

ADD DATABASE CofidisPayCore

GO





USE [master]

RESTORE DATABASE [CofidisPayCore] FROM  DISK = N'E:\backup\CofidisPayCore.bak' WITH  FILE = 1, 
	MOVE N'CofidisPayCore' TO N'E:\DATA\CofidisPayCore.mdf',  

	MOVE N'CofidisPayCore_log' TO N'L:\log\CofidisPayCore_Log.ldf',   NORECOVERY, NOUNLOAD,  STATS = 5
GO
---- RESTORE LOG ----

RESTORE LOG [CofidisPayCore] FROM  DISK = N'E:\backup\CofidisPayCore.trn' WITH  NORECOVERY,FILE = 1,  NOUNLOAD,  STATS = 5
GO

-- No primario
ALTER AVAILABILITY GROUP [AG] ADD DATABASE [CofidisPayCore];
/*On Secondary Node*/
ALTER DATABASE [CofidisPayCore] SET HADR AVAILABILITY GROUP = [AG];

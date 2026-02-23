



USE [master]

BACKUP DATABASE RiskLevel TO DISK = N'Y:\backup\RiskLevel.bak'
WITH INIT, COMPRESSION,  STATS = 10
Go
BACKUP LOG RiskLevel TO DISK = N'Y:\backup\RiskLevel.trn'
WITH INIT
Go


---

USE master

GO

ALTER AVAILABILITY GROUP AG

ADD DATABASE RiskLevel

GO





USE [master]

RESTORE DATABASE [RiskLevel] FROM  DISK = N'Y:\backup\RiskLevel.bak' WITH  FILE = 1, 
--	MOVE N'RiskLevel' TO N'Y:\DATA\RiskLevel.mdf',  
--		MOVE N'RiskLevel_idx' TO N'Y:\DATA\RiskLevel_idx.mdf',  
	
--	MOVE N'RiskLevel_log' TO N'Y:\log\RiskLevel_Log.ldf',   
 REPLACE, NORECOVERY, NOUNLOAD,  STATS = 5
GO
---- RESTORE LOG ----

RESTORE LOG [db_cofidis_dah] FROM  DISK = N'Y:\backup\RiskLevel.trn' WITH  NORECOVERY,FILE = 1,  NOUNLOAD,  STATS = 5
GO

-- No primario
ALTER AVAILABILITY GROUP [AG] ADD DATABASE [RiskLevel];
/*On Secondary Node*/
ALTER DATABASE [RiskLevel] SET HADR AVAILABILITY GROUP = [AG];

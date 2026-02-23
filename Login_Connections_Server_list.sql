SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

 
-- 1. create table

CREATE TABLE [dbo].[DBA_ConnectionCounts](
   [ServerName] [nvarchar](130) NOT NULL,
   [DatabaseName] [nvarchar](130) NOT NULL,
   [NumberOfConnections] [int] NOT NULL,
   [TimeStamp] [datetime] NOT NULL
);
GO
-- populate table
INSERT INTO [dbo].[DBA_ConnectionCounts]
SELECT @@ServerName AS [ServerName]
             ,NAME AS DatabaseName 
             ,COUNT(STATUS) AS [NumberOfConnections]
             ,GETDATE() AS [TimeStamp]
FROM sys.databases sd
LEFT JOIN master.dbo.sysprocesses sp ON sd.database_id = sp.dbid
WHERE database_id NOT BETWEEN 1 AND 4
GROUP BY NAME;
GO
--
-- number of records in ConnectionCounts
SELECT COUNT(*) FROM [dba_db].[dbo].[DBA_ConnectionCounts];
GO
 
-- oldest record in ConnectionCounts
SELECT MIN([TimeStamp])
FROM [dba_db].[dbo].[DBA_ConnectionCounts];
GO
 
-- identify likely unused databases
SELECT [ServerName]
      ,[DatabaseName]
      ,MAX([NumberOfConnections]) AS [NumberOfConnections] 
FROM [dba_db].[dbo].[DBA_ConnectionCounts]
GROUP BY [ServerName],[DatabaseName]
HAVING MAX([NumberOfConnections]) = 0
ORDER BY [ServerName],[DatabaseName];
GO
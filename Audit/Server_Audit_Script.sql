USE [master]
GO

/****** Object:  Audit [GDPR_GENREP_PSQL_GPF_BE_PRO_REP_Security_Audit]    Script Date: 12/10/2019 10:33:40 AM ******/
CREATE SERVER AUDIT [AUDIT_ARTEMIS_Security]
TO FILE 
(	FILEPATH = N'L:\AUDIT\SQLAudit\AG\'
	,MAXSIZE = 1024 MB
	,MAX_ROLLOVER_FILES = 2048
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
	
)
Use Master
--ALTER SERVER AUDIT [AUDIT_ARTEMIS_Security] WITH (STATE = ON)
--GO
ALTER SERVER AUDIT [AUDIT_ARTEMIS_Security] WITH (STATE = OFF);
GO
ALTER SERVER AUDIT [AUDIT_ARTEMIS_Security] WHERE server_principal_name <> N'COFIDIS2000\IIS_COFINETAPI' and server_principal_name <> 'COFIDIS2000\cofptpsqldba01-mon'
and server_principal_name <> 'NT AUTHORITY\SYSTEM';
GO
ALTER SERVER AUDIT [AUDIT_ARTEMIS_Security] WITH (STATE = ON);
GO


USE [Cofinet]
GO


CREATE DATABASE AUDIT SPECIFICATION [DB_Cofinet_Security_Audit]
FOR SERVER AUDIT [AUDIT_ARTEMIS_Security]
ADD (UPDATE ON DATABASE::[Cofinet] BY [public]),
ADD (SELECT ON DATABASE::[Cofinet] BY [public]),
ADD (INSERT ON DATABASE::[Cofinet] BY [public]),
ADD (DELETE ON DATABASE::[Cofinet] BY [public])
--ADD (EXECUTE ON DATABASE::[Cofinet] BY [public]),
--ADD (DATABASE_OBJECT_CHANGE_GROUP),
--ADD (SCHEMA_OBJECT_CHANGE_GROUP)
WITH (STATE = ON)
GO

-- Teste select
USE [Cofinet]
GO
SELECT TOP (1000) [Id]   ,[Name]     ,[Description]  FROM [Cofinet].[dbo].[LoginState]

-- Check the audit for the filtered content
SELECT * FROM fn_get_audit_file('L:\AUDIT\SQLAudit\AG\Audit_ARTEMIS_Security*.sqlaudit',default,default);
GO



-- Disable Auditing
use Master;
go
ALTER SERVER AUDIT [AUDIT_ARTEMIS_Security] WITH (STATE = OFF);
GO

Use Cofinet;
go
ALTER DATABASE AUDIT SPECIFICATION [DB_Cofinet_Security_Audit] 
  WITH (STATE = OFF);  
  go

Use Cofinet;
go
drop  DATABASE AUDIT SPECIFICATION [DB_Cofinet_Security_Audit]
USE [master]
GO

/****** Object:  Audit [GDPR_GENREP_PSQL_GPF_BE_PRO_REP_Security_Audit]    Script Date: 12/10/2019 10:33:40 AM ******/
CREATE SERVER AUDIT [AUDIT_ARTEMIS_Security]
TO FILE 
(	FILEPATH = N'L:\AUDIT\SQLAudit\AG\Cofinet\'
	,MAXSIZE = 1024 MB
	,MAX_ROLLOVER_FILES = 50
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 2000
	,ON_FAILURE = CONTINUE
	
)
Use Master
go
--ALTER SERVER AUDIT [AUDIT_ARTEMIS_Security] WITH (STATE = ON)
--GO
ALTER SERVER AUDIT [AUDIT_ARTEMIS_Security] WITH (STATE = OFF);
GO
Use Master
go
ALTER SERVER AUDIT [AUDIT_ARTEMIS_Security] WHERE server_principal_name <> 'COFIDIS2000\cofptpsqldba01-mon'
and server_principal_name <> 'NT AUTHORITY\SYSTEM'   and server_principal_name <> 'COFIDIS2000\IIS_COFINETAPI';
GO
Use Master
go
ALTER SERVER AUDIT [AUDIT_ARTEMIS_Security] WITH (STATE = ON);
GO

USE [Cofinet]
GO
CREATE DATABASE AUDIT SPECIFICATION [DB_Cofinet_Security_Audit]
FOR SERVER AUDIT [AUDIT_ARTEMIS_Security]
    ADD (SELECT, UPDATE, DELETE, INSERT, EXECUTE ON SCHEMA::dbo BY PUBLIC)
    WITH (STATE = ON);
GO


-- Teste select
USE [Cofinet]
GO
SELECT TOP (1000) [Id]   ,[Name]     ,[Description]  FROM [Cofinet].[dbo].[LoginState]

-- Check the audit for the filtered content
SELECT top(1000) * FROM fn_get_audit_file('L:\AUDIT\SQLAudit\AG\Cofinet\Audit_ARTEMIS_Security*.sqlaudit',default,default)
order by event_time desc;
GO
-- ou

SELECT event_time
,sequence_number
,action_id
,server_principal_name
,server_instance_name
,database_name
,schema_name
,object_name
,statement
FROM sys.fn_get_audit_file('L:\AUDIT\SQLAudit\AG\Cofinet\Audit_ARTEMIS_Security*.sqlaudit', DEFAULT, DEFAULT)

Use Cofinet
go

/*
drop view dbo.Auditdata
go
CREATE view [dbo].[AuditData] as
SELECT event_time
,action_id
,server_principal_name
,server_instance_name
,database_name
,schema_name
,object_name
,statement
FROM sys.fn_get_audit_file('L:\AUDIT\SQLAudit\AG\Cofinet\Audit_ARTEMIS_Security*.sqlaudit', DEFAULT, DEFAULT)
GO

select * from [dbo].[AuditData]
*/

SELECT  COUNT(*) ActionsCount ,
        f.action_id ,
        a.name ,
        a.class_desc
FROM    sys.fn_get_audit_file('L:\AUDIT\SQLAudit\AG\Cofinet\Audit_ARTEMIS_Security*.sqlaudit',
                              DEFAULT, DEFAULT) f
        JOIN sys.dm_audit_actions a ON a.action_id = f.action_id
GROUP BY f.action_id ,
        a.name ,
        a.class_desc;



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

use master
go
DROP SERVER AUDIT AUDIT_ARTEMIS_Security;  
GO 
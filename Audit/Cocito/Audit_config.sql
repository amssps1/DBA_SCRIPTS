USE [master]
GO

/****** Object:  Audit [GDPR_GENREP_PSQL_GPF_BE_PRO_REP_Security_Audit]    Script Date: 12/10/2019 10:33:40 AM ******/
CREATE SERVER AUDIT [AUDIT_COCITO_Security]
TO FILE 
(	FILEPATH = N'S:\AUDIT\'
	,MAXSIZE = 512 MB
	,MAX_ROLLOVER_FILES = 10
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
ALTER SERVER AUDIT [AUDIT_COCITO_Security] WITH (STATE = OFF);
GO
Use Master
go
ALTER SERVER AUDIT [AUDIT_COCITO_Security] WHERE server_principal_name <> 'COFIDIS2000\cofptpsqldba01-mon'
and server_principal_name <> 'NT AUTHORITY\SYSTEM'   and server_principal_name <> 'cofidis2000\prod_api_rh' 
and server_principal_name <> 'cofidis2000\prod_bc_rh' and server_principal_name <> 'COFIDIS2000\prod_sql_edigital' and server_principal_name <>'uEDAvalDesemp'
and server_principal_name <> 'COFIDIS2000\prod_sql_agt_cocito';
GO
Use Master
go
ALTER SERVER AUDIT [AUDIT_COCITO_Security] WITH (STATE = ON);
GO


USE [RH-BusinessCentral]
GO

CREATE DATABASE AUDIT SPECIFICATION [DB_BusinessCentral_Security_Audit]
FOR SERVER AUDIT [AUDIT_COCITO_Security]
    ADD (SELECT, UPDATE, DELETE, INSERT, EXECUTE ON SCHEMA::dbo BY PUBLIC)
    WITH (STATE = ON);
GO

/*
CREATE DATABASE AUDIT SPECIFICATION [DB_BusinessCentral_Security_Audit]
FOR SERVER AUDIT [AUDIT_COCITO_Security]
ADD (UPDATE ON DATABASE::[RH-BusinessCentral] BY [public]),
ADD (SELECT ON DATABASE::[RH-BusinessCentral] BY [public]),
ADD (INSERT ON DATABASE::[RH-BusinessCentral] BY [public]),
ADD (DELETE ON DATABASE::[RH-BusinessCentral] BY [public])
--ADD (EXECUTE ON DATABASE::[Cofinet] BY [public]),
--ADD (DATABASE_OBJECT_CHANGE_GROUP),
--ADD (SCHEMA_OBJECT_CHANGE_GROUP)
WITH (STATE = ON)
GO
*/

USE [EDAvalDesemp]
GO

CREATE DATABASE AUDIT SPECIFICATION [DB_EDAvalDesemp_Security_Audit]
FOR SERVER AUDIT [AUDIT_COCITO_Security]
    ADD (SELECT, UPDATE, DELETE, INSERT, EXECUTE ON SCHEMA::dbo BY PUBLIC)
    WITH (STATE = ON);
GO
/*
CREATE DATABASE AUDIT SPECIFICATION [DB_EDAvalDesemp_Security_Audit]
FOR SERVER AUDIT [AUDIT_COCITO_Security]
ADD (UPDATE ON DATABASE::[EDAvalDesemp] BY [public]),
ADD (SELECT ON DATABASE::[EDAvalDesemp] BY [public]),
ADD (INSERT ON DATABASE::[EDAvalDesemp] BY [public]),
ADD (DELETE ON DATABASE::[EDAvalDesemp] BY [public])
WITH (STATE = ON)
GO
*/
-- Teste select
USE [EDAvalDesemp]
GO
-- Check the audit for the filtered content
SELECT  * FROM fn_get_audit_file('S:\AUDIT\AUDIT_COCITO_Security*.sqlaudit',default,default)
--WHERE schema_name <> 'sys'
order by event_time desc;
GO

------------------------------------------------------------------------------------------------
-- Teste select
USE [RH-BusinessCentral]
GO
-- Check the audit for the filtered content
SELECT top(1000) * FROM fn_get_audit_file('S:\AUDIT\AUDIT_COCITO_Security*.sqlaudit',default,default)
WHERE schema_name <> 'sys'
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
FROM sys.fn_get_audit_file('S:\AUDIT\AUDIT_COCITO_Security*.sqlaudit',default,default)

Use [RH-BusinessCentral]
go

SELECT  COUNT(*) ActionsCount ,
        f.action_id ,
        a.name ,
        a.class_desc
FROM   sys.fn_get_audit_file('S:\AUDIT\AUDIT_COCITO_Security*.sqlaudit',default,default) f
        JOIN sys.dm_audit_actions a ON a.action_id = f.action_id
GROUP BY f.action_id ,
        a.name ,
        a.class_desc;













-- Disable Auditing
use Master;
go
ALTER SERVER AUDIT [AUDIT_COCITO_Security] WITH (STATE = OFF);
GO

Use [RH-BusinessCentral];
go
ALTER DATABASE AUDIT SPECIFICATION [DB_BusinessCentral_Security_Audit] 
  WITH (STATE = OFF);  
  go

Use [EDAvalDesemp];
go
ALTER DATABASE AUDIT SPECIFICATION [DB_EDAvalDesemp_Security_Audit] 
  WITH (STATE = OFF);  
  go

Use [RH-BusinessCentral];
go
drop  DATABASE AUDIT SPECIFICATION [DB_BusinessCentral_Security_Audit]


Use [EDAvalDesemp];
go
drop  DATABASE AUDIT SPECIFICATION [DB_EDAvalDesemp_Security_Audit]


use master
go
DROP SERVER AUDIT AUDIT_COCITO_Security;  
GO 
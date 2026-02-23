

USE [master]
GO

/****** Object:  Audit [GDPR_GENREP_PSQL_GPF_BE_PRO_REP_Security_Audit]    Script Date: 12/10/2019 10:33:40 AM ******/
CREATE SERVER AUDIT [AUDIT_ARTEMIS_Security_Logins]
TO FILE 
(	FILEPATH = N'L:\AUDIT\SQLAudit\AG\LOGINS'
	,MAXSIZE = 512 MB
	,MAX_ROLLOVER_FILES = 10
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 2000
	,ON_FAILURE = CONTINUE
	
)

-- Enable the audit
ALTER SERVER AUDIT SuccessfulLoginsAudit WITH (STATE = ON);

-- Create audit specification
CREATE SERVER AUDIT SPECIFICATION SuccessfulLoginsSpec
FOR SERVER AUDIT SuccessfulLoginsAudit
ADD (SUCCESSFUL_LOGIN_GROUP),
ADD (FAILED_LOGIN_GROUP);



Use Master
--ALTER SERVER AUDIT [AUDIT_ARTEMIS_Security] WITH (STATE = ON)
--GO
ALTER SERVER AUDIT [AUDIT_ARTEMIS_Security] WITH (STATE = OFF);
GO
ALTER SERVER AUDIT [AUDIT_ARTEMIS_Security] WHERE server_principal_name not in ('COFIDIS2000\IIS_COFINETAPI' ,'COFIDIS2000\cofptpsqldba01-mon',
'NT AUTHORITY\SYSTEM',
'COFIDIS2000\administrator',
'NT SERVICE\SQLWriter',
'NT SERVICE\Winmgmt',
'NT SERVICE\MSSQLSERVER',
'NT SERVICE\ClusSvc',
'NT AUTHORITY\SYSTEM',
'NT SERVICE\SQLSERVERAGENT',
'BUILTIN\Administrators',
'NT AUTHORITY\NETWORK SERVICE',
'COFIDIS2000\icmadmin',
'COFIDIS2000\IIS_APOLO',
'COFIDIS2000\filewatcher',
'WCFCofidis',
'COFIDIS2000\iis_ceyonic',
'COFIDIS2000\accipiens',
'COFIDIS2000\odmservice',
'COFIDIS2000\iis_apoloapi',
'COFIDIS2000\docDigitizer',
'CC360owner',
'grafana_readonly',
'cofidis2000\prod_selfcareapi',
'cofidis2000\prod_rgpdapi',
'cofidis2000\prod_feedbackapi',
'COFIDIS2000\iis_wscomunicacao',


);
GO
ALTER SERVER AUDIT [AUDIT_ARTEMIS_Security] WITH (STATE = ON);
GO
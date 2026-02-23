-- UAT - UATCARLSBERG
--  Linked Server para Ligação do UATPERSEU ao UATCARLSBERG
--   nome do Login : LinkedPA

use master
go
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'LinkedPA')
     DROP LOGIN [LinkedPA];
GO  

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'LinkedPA')
 --    CREATE LOGIN [LinkedPA] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english];
 --	 IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = '#{Cofidis.User.Webservice}#')
     CREATE LOGIN [LinkedPA] WITH PASSWORD='4iYASv^jg=arprzlxW|Jqd+' , DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
 Go
    
GO    

EXEC sp_MSforeachdb '
IF ''?'' IN (''dotnetnuke'', ''db_cofidis_dah'', ''IDH'', ''FM''
,''TcontrolDAH''

) 
BEGIN 
    USE [?]
    PRINT ''?''
	DROP SCHEMA IF EXISTS [LinkedPA];
	DROP USER IF EXISTS [LinkedPA]

    IF DATABASE_PRINCIPAL_ID(''LinkedPA'') IS NULL
    BEGIN
        PRINT '' Criando o Linked Server user.''
        CREATE USER [LinkedPA] FROM LOGIN [LinkedPA];
    END /*IF*/
    PRINT '' Adicionar as permissões para o user ...''
	GRANT CONNECT TO [LinkedPA]
	GRANT SELECT, INSERT, UPDATE,Delete TO [LinkedPA] 
	GRANT EXECUTE 				TO [LinkedPA]
	

END /*IF*/
'


/*
--Privilégios outsystems
*/
USE [outsystems]
GO
DROP SCHEMA IF EXISTS [LinkedPA]
DROP USER IF EXISTS [LinkedPA]
go
IF NOT EXISTS (SELECT NAME FROM sys.database_principals WHERE NAME =  'LinkedPA') BEGIN CREATE USER  [LinkedPA] 
   FOR LOGIN [LinkedPA] END ELSE ALTER USER  [LinkedPA] WITH LOGIN = [LinkedPA];
IF DATABASE_PRINCIPAL_ID('LinkedPA') IS NOT NULL GRANT CONNECT TO [LinkedPA]

  GRANT SELECT, INSERT, UPDATE,Delete on OSUSR_OZM_USERDETAIL TO [LinkedPA] 


/*
--Privilégios DSTI
*/
USE [DSTI]
GO
DROP SCHEMA IF EXISTS [LinkedPA]
DROP USER IF EXISTS [LinkedPA]
go
IF NOT EXISTS (SELECT NAME FROM sys.database_principals WHERE NAME =  'LinkedPA') BEGIN CREATE USER  [LinkedPA] 
   FOR LOGIN [LinkedPA] END ELSE ALTER USER  [LinkedPA] WITH LOGIN = [LinkedPA];
IF DATABASE_PRINCIPAL_ID('LinkedPA') IS NOT NULL GRANT CONNECT TO [LinkedPA]

  GRANT SELECT, INSERT, UPDATE,Delete on SDK_Avaria TO [LinkedPA] 
  GRANT SELECT, INSERT, UPDATE,Delete on portal_tipoficheiro_aux TO [LinkedPA] 
  GRANT SELECT, INSERT, UPDATE,Delete on portal_tipoficheiro_auxSFTP TO [LinkedPA] 



/*
--Privilégios FileWatcher
*/
USE [FileWatcher]
GO
DROP SCHEMA IF EXISTS [LinkedPA]
DROP USER IF EXISTS [LinkedPA]
go
IF NOT EXISTS (SELECT NAME FROM sys.database_principals WHERE NAME =  'LinkedPA') BEGIN CREATE USER  [LinkedPA] 
   FOR LOGIN [LinkedPA] END ELSE ALTER USER  [LinkedPA] WITH LOGIN = [LinkedPA];
IF DATABASE_PRINCIPAL_ID('LinkedPA') IS NOT NULL GRANT CONNECT TO [LinkedPA]

  GRANT SELECT, INSERT, UPDATE,Delete on Execucao TO [LinkedPA] 


/*
--Privilégios FileWatcher
*/
USE [dotnetnuke]
GO
DROP SCHEMA IF EXISTS [LinkedPA]
DROP USER IF EXISTS [LinkedPA]
go
IF NOT EXISTS (SELECT NAME FROM sys.database_principals WHERE NAME =  'LinkedPA') BEGIN CREATE USER  [LinkedPA] 
   FOR LOGIN [LinkedPA] END ELSE ALTER USER  [LinkedPA] WITH LOGIN = [LinkedPA];
IF DATABASE_PRINCIPAL_ID('LinkedPA') IS NOT NULL GRANT CONNECT TO [LinkedPA]

  GRANT SELECT on users TO [LinkedPA] 
  GRANT SELECT on COFIDIS_Organizacao TO [LinkedPA] 


/*
--Privilégios CobrancasDAH
*/
USE [CobrancasDAH]
GO
DROP SCHEMA IF EXISTS [LinkedPA]
DROP USER IF EXISTS [LinkedPA]
go
IF NOT EXISTS (SELECT NAME FROM sys.database_principals WHERE NAME =  'LinkedPA') BEGIN CREATE USER  [LinkedPA] 
   FOR LOGIN [LinkedPA] END ELSE ALTER USER  [LinkedPA] WITH LOGIN = [LinkedPA];
IF DATABASE_PRINCIPAL_ID('LinkedPA') IS NOT NULL GRANT CONNECT TO [LinkedPA]

	GRANT SELECT, INSERT, UPDATE,Delete TO [LinkedPA] 
	GRANT EXECUTE 						TO [LinkedPA]
    GRANT ALTER							TO [LinkedPA] 


/*
--Privilégios RUP
*/
USE [RUP]
GO
DROP SCHEMA IF EXISTS [LinkedPA]
DROP USER IF EXISTS [LinkedPA]
go
IF NOT EXISTS (SELECT NAME FROM sys.database_principals WHERE NAME =  'LinkedPA') BEGIN CREATE USER  [LinkedPA] 
   FOR LOGIN [LinkedPA] END ELSE ALTER USER  [LinkedPA] WITH LOGIN = [LinkedPA];
IF DATABASE_PRINCIPAL_ID('LinkedPA') IS NOT NULL GRANT CONNECT TO [LinkedPA]

	GRANT SELECT, INSERT, UPDATE,Delete ON proposta TO [LinkedPA] 




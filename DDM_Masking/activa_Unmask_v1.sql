-- Todos os ambientes
--  COFIDIS2000\GRP_SQL_EXT_PRD
--  

/*
1º Correr a Script de aplicação de Masking
2º Correr esta script para que todos os Logins possam ver os dados
*/

-- Atribuir Unmask a todos os Database Users    
use IDH
go
	DECLARE @name NVARCHAR(100)

	DECLARE db_Logins_Users CURSOR FOR 
	SELECT
	u.name AS [Name]
	FROM
	sys.database_principals AS u
	LEFT OUTER JOIN sys.database_permissions AS dp ON dp.grantee_principal_id = u.principal_id and dp.type = 'CO'
	WHERE
	(u.type in ('U', 'S', 'G', 'C', 'K' ,'E', 'X'))
	and u.name not in ('guest','sys','dbo') and dp.state ='G'

	OPEN db_Logins_Users  
	FETCH NEXT FROM db_Logins_Users INTO @name  

	WHILE @@FETCH_STATUS = 0  
	BEGIN 
	       EXEC('GRANT UNMASK TO [' + @name + ']') 
		  --GRANT UNMASK TO N'@name'
          PRINT 'Aplicar Unmask ao User: ' + @name 
		  FETCH NEXT FROM db_Logins_Users INTO @name 
	END 

	CLOSE db_Logins_Users  
	DEALLOCATE db_Logins_Users


-- Criar Login Externos
use master
go
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'COFIDIS2000\GRP_SQL_EXT_PRD')
     DROP LOGIN [COFIDIS2000\GRP_SQL_EXT_PRD];
GO  
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'COFIDIS2000\GRP_SQL_EXT_PRD')
     CREATE LOGIN [COFIDIS2000\GRP_SQL_EXT_PRD] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english];
GO


EXEC sp_MSforeachdb '
IF ''?'' IN (''IDH'') 
BEGIN 
    USE [?]
    PRINT ''?''
	DROP USER IF EXISTS [COFIDIS2000\GRP_SQL_EXT_PRD]

    IF DATABASE_PRINCIPAL_ID(''COFIDIS2000\GRP_SQL_EXT_PRD'') IS NULL
    BEGIN
        PRINT '' Criando o user.''
        CREATE USER [COFIDIS2000\GRP_SQL_EXT_PRD] FROM LOGIN [COFIDIS2000\GRP_SQL_EXT_PRD];
    END 
	
    PRINT '' Adicionar as permissões para o user ...''
	GRANT CONNECT TO [COFIDIS2000\GRP_SQL_EXT_PRD]
	GRANT select on COF_Cliente  			TO [COFIDIS2000\GRP_SQL_EXT_PRD]
	GRANT select on COF_ClienteUProcesso 	TO [COFIDIS2000\GRP_SQL_EXT_PRD]
	GRANT select on COF_Processo  TO [COFIDIS2000\GRP_SQL_EXT_PRD]
	GRANT select on Cof_baseriscoDAH  TO [COFIDIS2000\GRP_SQL_EXT_PRD]
	GRANT select on COF_Referencias TO [COFIDIS2000\GRP_SQL_EXT_PRD]
	GRANT select on COF_ContactoTelefonico  TO [COFIDIS2000\GRP_SQL_EXT_PRD]
	GRANT select on DAH_Produto  TO [COFIDIS2000\GRP_SQL_EXT_PRD]
	GRANT select on VG_CarteiraDossier  TO [COFIDIS2000\GRP_SQL_EXT_PRD] 
	grant select ON  OCR_PEDIDO 	TO [COFIDIS2000\GRP_SQL_EXT_PRD]
	grant select ON  OCR_RESPOSTA	TO [COFIDIS2000\GRP_SQL_EXT_PRD]


	


END /*IF*/
'
/*
--Privilégios Adicionais
*/


USE [PaymentGateway]
go

DROP USER IF EXISTS [COFIDIS2000\GRP_SQL_EXT_PRD]

IF DATABASE_PRINCIPAL_ID('COFIDIS2000\GRP_SQL_EXT_PRD') IS NULL
BEGIN
    PRINT ' Criando o user.'
    CREATE USER [COFIDIS2000\GRP_SQL_EXT_PRD] FROM LOGIN [COFIDIS2000\GRP_SQL_EXT_PRD];
END 

EXEC sp_addrolemember 'db_datareader', [COFIDIS2000\GRP_SQL_EXT_PRD]




/*
--Privilégios MSDB
*/
USE [msdb]
GO
DROP SCHEMA IF EXISTS [COFIDIS2000\GRP_SQL_EXT_PRD]
DROP USER IF EXISTS [COFIDIS2000\GRP_SQL_EXT_PRD]
go
IF NOT EXISTS (SELECT NAME FROM sys.database_principals WHERE NAME =  'COFIDIS2000\GRP_SQL_EXT_PRD') BEGIN CREATE USER  [COFIDIS2000\GRP_SQL_EXT_PRD] 
   FOR LOGIN [COFIDIS2000\GRP_SQL_EXT_PRD] END ELSE ALTER USER  [COFIDIS2000\GRP_SQL_EXT_PRD] WITH LOGIN = [COFIDIS2000\GRP_SQL_EXT_PRD];
IF DATABASE_PRINCIPAL_ID('COFIDIS2000\GRP_SQL_EXT_PRD') IS NOT NULL GRANT CONNECT TO [COFIDIS2000\GRP_SQL_EXT_PRD]

exec sp_addrolemember 'SQLAgentUserRole', 'COFIDIS2000\GRP_SQL_EXT_PRD'
exec sp_addrolemember 'db_ssisoperator', 'COFIDIS2000\GRP_SQL_EXT_PRD'
exec sp_addrolemember 'db_datareader', 'COFIDIS2000\GRP_SQL_EXT_PRD'

/*
--Privilégios SSISDB
*/
USE [SSISDB]
GO
DROP USER IF EXISTS [COFIDIS2000\GRP_SQL_EXT_PRD]
go
IF NOT EXISTS (SELECT NAME FROM sys.database_principals WHERE NAME =  'COFIDIS2000\GRP_SQL_EXT_PRD') BEGIN CREATE USER  [COFIDIS2000\GRP_SQL_EXT_PRD] 
   FOR LOGIN [COFIDIS2000\GRP_SQL_EXT_PRD] END ELSE ALTER USER  [COFIDIS2000\GRP_SQL_EXT_PRD] WITH LOGIN = [COFIDIS2000\GRP_SQL_EXT_PRD];
IF DATABASE_PRINCIPAL_ID('COFIDIS2000\GRP_SQL_EXT_PRD') IS NOT NULL GRANT CONNECT TO [COFIDIS2000\GRP_SQL_EXT_PRD]

ALTER ROLE [db_datareader] ADD MEMBER [COFIDIS2000\GRP_SQL_EXT_PRD]
GO





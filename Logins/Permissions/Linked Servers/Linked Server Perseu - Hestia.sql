-- UAT - UATCARLSBERG
--  Linked Server para Ligação do UATPERSEU ao UATCARLSBERG
--   nome do Login : LinkedPA

use master
go
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'LinkedPH')
     DROP LOGIN [LinkedPH];
GO  

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'LinkedPH')
 --    CREATE LOGIN [LinkedPH] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english];
 --	 IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = '#{Cofidis.User.Webservice}#')
     CREATE LOGIN [LinkedPH] WITH PASSWORD='TZWHfWJ6EzwSHNdo.AiTGlh' , DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
 Go
    
GO    


/*
--Privilégios Lusiadas
*/
USE [Lusiadas]
GO
DROP SCHEMA IF EXISTS [LinkedPH]
DROP USER IF EXISTS [LinkedPH]
go
IF NOT EXISTS (SELECT NAME FROM sys.database_principals WHERE NAME =  'LinkedPH') BEGIN CREATE USER  [LinkedPH] 
   FOR LOGIN [LinkedPH] END ELSE ALTER USER  [LinkedPH] WITH LOGIN = [LinkedPH];
IF DATABASE_PRINCIPAL_ID('LinkedPH') IS NOT NULL GRANT CONNECT TO [LinkedPH]

    GRANT SELECT on v_OUTPUT_DAH_CriteriosFinancDefault TO [LinkedPH] 
	GRANT SELECT on v_OUTPUT_DAH_Default TO [LinkedPH] 
	GRANT SELECT on v_OUTPUT_DAH_CR_NiveisIncumprimentoDossier TO [LinkedPH] 
	GRANT SELECT on CR_Dim_NiveisIncumprimentoDossier TO [LinkedPH] 
	GRANT SELECT on  CR_Fact_Movimento TO [LinkedPH] 


/*
--Privilégios Lusiadas
*/
USE [reportesbdp]
GO
DROP SCHEMA IF EXISTS [LinkedPH]
DROP USER IF EXISTS [LinkedPH]
go
IF NOT EXISTS (SELECT NAME FROM sys.database_principals WHERE NAME =  'LinkedPH') BEGIN CREATE USER  [LinkedPH] 
   FOR LOGIN [LinkedPH] END ELSE ALTER USER  [LinkedPH] WITH LOGIN = [LinkedPH];
IF DATABASE_PRINCIPAL_ID('LinkedPH') IS NOT NULL GRANT CONNECT TO [LinkedPH]

    GRANT SELECT on COF_U_CentraRiscoBP_CDEV_BancoCofidis TO [LinkedPH] 
	GRANT SELECT on cof_u_centrariscobp_cdev_cofidis TO [LinkedPH] 
	GRANT SELECT on NIFSBancoCofidis TO [LinkedPH] 
	GRANT SELECT on COF_U_CentraRiscoBP_CDEV_BancoCofidis to [LinkedPH] 
	GRANT SELECT on  COF_U_CentraRiscoBP_CSLD_Cofidis TO [LinkedPH] 
	GRANT SELECT on  CRC_Adendas TO [LinkedPH] 





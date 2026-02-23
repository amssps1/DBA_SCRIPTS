



DELETE

FROM [Interfacesdah].[dbo].[COF_U_CtrlSaldosDetalhe]

where cast(DtProcessamento as date) <= (dateadd(YEAR, -1, getdate()))

1602027119 linhas



  
 DECLARE @Deleted_Rows INT;
 SET @Deleted_Rows = 1;


 WHILE (@Deleted_Rows > 0)
   BEGIN
    BEGIN transaction
    -- Delete some small number of rows at a time
	    
    DELETE TOP (100000)  FROM [Interfacesdah].[dbo].[COF_U_CtrlSaldosDetalhe]
    where cast(DtProcessamento as date) <= (dateadd(YEAR, -1, getdate()));
    SET @Deleted_Rows = @@ROWCOUNT;
	COMMIT TRANSACTION
	PRINT @Deleted_Rows
    waitfor DELAY '00:00:00:100'
 END
 










-----------------------

DELETE

FROM [Interfacesdah].[dbo].[COF_U_DossierSeguro]

where cast(DtProcessamento as date) <= (dateadd(month, -6, getdate()))

64713196 linhas



  
 DECLARE @Deleted_Rows INT;
 SET @Deleted_Rows = 1;


 WHILE (@Deleted_Rows > 0)
   BEGIN
    BEGIN transaction
    -- Delete some small number of rows at a time
	    
    DELETE TOP (200000)  FROM [Interfacesdah].[dbo].[COF_U_DossierSeguro]

    where cast(DtProcessamento as date) <= (dateadd(month, -6, getdate()));
    SET @Deleted_Rows = @@ROWCOUNT;
	COMMIT TRANSACTION
	PRINT @Deleted_Rows
    waitfor DELAY '00:00:00:50'
 END
 


--- Done



-----------------------

DELETE pm

FROM db_cofidis_dah_interface_aux.dbo.PrestacaoMora pm

INNER JOIN db_cofidis_dah_interface_aux.dbo.Dossier d ON pm.NumDossier = d.NumDossier

WHERE d.CodSitDossier IN ('T', 'V')

AND d.DtSitDossier < DATEADD(MONTH, -1, GETDATE())

243104551 linhas


 SET NOCOUNT ON;
 DECLARE @Deleted_Rows INT;
 SET @Deleted_Rows = 1;


 WHILE (@Deleted_Rows > 0)
   BEGIN
    BEGIN transaction
	    
    DELETE TOP (100000) pm 
	from  db_cofidis_dah_interface_aux.dbo.PrestacaoMora pm
	INNER JOIN db_cofidis_dah_interface_aux.dbo.Dossier d 
	ON pm.NumDossier = d.NumDossier
    WHERE d.CodSitDossier IN ('T', 'V')
      AND d.DtSitDossier < DATEADD(MONTH, -1, GETDATE());
    
	SET @Deleted_Rows = @@ROWCOUNT;
	COMMIT TRANSACTION
	PRINT @Deleted_Rows
    waitfor DELAY '00:00:00:50'

 END
 







-----------------------

DELETE pm

FROM db_cofidis_dah.dbo.PrestacaoMora pm

INNER JOIN db_cofidis_dah.dbo.Dossier d ON pm.NumDossier = d.NumDossier

WHERE d.CodSitDossier IN ('T', 'V')

AND d.DtSitDossier < DATEADD(MONTH, -1, GETDATE())



 DECLARE @Deleted_Rows INT;
 SET @Deleted_Rows = 1;


 WHILE (@Deleted_Rows > 0)
   BEGIN
    BEGIN transaction
	    
    DELETE TOP (100000) pm 	from  db_cofidis_dah.dbo.PrestacaoMora pm
	INNER JOIN db_cofidis_dah.dbo.Dossier d ON pm.NumDossier = d.NumDossier

    WHERE d.CodSitDossier IN ('T', 'V')
      AND d.DtSitDossier < DATEADD(MONTH, -1, GETDATE());
    
	SET @Deleted_Rows = @@ROWCOUNT;
	COMMIT TRANSACTION
	PRINT @Deleted_Rows
    waitfor DELAY '00:00:00:50'

 END
 



243103589 linhas

-----------------------

DELETE Interfacesdah..COF_Maturidades WHERE IdMes < 202503

 DECLARE @Deleted_Rows INT;
 SET @Deleted_Rows = 1;


 WHILE (@Deleted_Rows > 0)
   BEGIN
    BEGIN transaction
	    
    DELETE TOP (100000) Interfacesdah..COF_Maturidades
    WHERE IdMes < 202503;
    
	SET @Deleted_Rows = @@ROWCOUNT;
	COMMIT TRANSACTION
	PRINT @Deleted_Rows
    waitfor DELAY '00:00:00:50'
	IF @@ROWCOUNT = 0 
        BREAK;  -- sai quando já não há mais registos para apagar
 END
 





332853081 linhas

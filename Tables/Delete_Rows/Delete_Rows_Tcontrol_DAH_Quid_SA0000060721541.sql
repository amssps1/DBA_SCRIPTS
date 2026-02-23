SET NOCOUNT ON;
DECLARE @Deleted_Rows int = 1;
DECLARE @BatchSize   int = 10000; -- ajusta conforme necessário

WHILE (@Deleted_Rows > 0)
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        DELETE TOP (@BatchSize) t
        FROM [TcontrolDAH].[dbo].[TCD_Transaction]  t
        INNER JOIN [db_cofidis_dah].[dbo].[Dossier] d ON t.numdossier=d.NumDossier
        WHERE CodSitDossier in ( 'T', 'V')
        AND (cast(DtSitDossier AS DATE) <= DATEADD(YEAR, -5, GETDATE())  AND CASt(CreatedDate AS DATE ) <= DATEADD(YEAR, -5, GETDATE()))
        AND t.numdossier > 0 

        SET @Deleted_Rows = @@ROWCOUNT;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;

        DECLARE @Err NVARCHAR(4000) =
            CONCAT('Erro: ', ERROR_NUMBER(), ' - ', ERROR_MESSAGE());
        RAISERROR(@Err, 16, 1);
        BREAK;
    END CATCH;

    PRINT CONCAT('Apagadas: ', @Deleted_Rows);

    -- 50 milissegundos (usa 00:00:50 se queres 50 segundos)
    WAITFOR DELAY '00:00:02.000';
END;



--KILL 663


  --SELECT count (id)
  --FROM [TcontrolDAH].[dbo].[TCD_Transaction] t
  --INNER JOIN [db_cofidis_dah].[dbo].[Dossier] d ON t.numdossier=d.NumDossier
  --WHERE CodSitDossier in ( 'T', 'V')
  --AND (cast(DtSitDossier AS DATE) <= DATEADD(YEAR, -5, GETDATE())  AND CASt(CreatedDate AS DATE ) <= DATEADD(YEAR, -5, GETDATE()))
  --AND t.numdossier > 0 

  --DELETE t
  --FROM [TcontrolDAH].[dbo].[TCD_Transaction] t
  --INNER JOIN [db_cofidis_dah].[dbo].[Dossier] d ON t.numdossier=d.NumDossier
  --WHERE CodSitDossier in ( 'T', 'V')
  --AND (cast(DtSitDossier AS DATE) <= DATEADD(YEAR, -5, GETDATE())  AND CASt(CreatedDate AS DATE ) <= DATEADD(YEAR, -5, GETDATE()))
  --AND t.numdossier > 0 

  -- --Count Nr transacoes
  -- --7 482 848
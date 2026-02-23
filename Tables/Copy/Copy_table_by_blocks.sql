DECLARE @BatchSize INT = 1000; -- Number of records per batch
DECLARE @Offset INT = 0;       -- Starting point for each batch
DECLARE @RowCount INT = 1;     -- Number of rows copied in the last batch

SET IDENTITY_INSERT ComunicacaoProcessada_NEW ON
-- Loop until no rows are left to copy
WHILE @RowCount > 0
BEGIN
    -- Copy a batch of records from SourceTable to CloneTable
    INSERT INTO [dbo].[ComunicacaoProcessada_NEW]
           (IdComunicacaoProcessada
		   ,[CreatedByUser]
           ,[CreatedDate]
           ,[UpdatedByUser]
           ,[UpdatedDate]
           ,[XMLData]
           ,[IdEstado]
           ,[IdAplicacao]
           ,[LogProcessamento]
           ,[IdTarefa]
           ,[DataEnvio]
           ,[IdComunicacaoProcessadaMain]
           ,[Log]
           ,[IdComAssociada]
           ,[IdTipoEntidadeComunicacao]
           ,[IdTipoEnvioComunicacao]
           ,[IdReferenciaComunicacaoTemplate])  
    SELECT TOP (@BatchSize) 	 [IdComunicacaoProcessada]
      ,[CreatedByUser]
      ,[CreatedDate]
      ,[UpdatedByUser]
      ,[UpdatedDate]
      ,[XMLData]
      ,[IdEstado]
      ,[IdAplicacao]
      ,[LogProcessamento]
      ,[IdTarefa]
      ,[DataEnvio]
      ,[IdComunicacaoProcessadaMain]
      ,[Log]
      ,[IdComAssociada]
      ,[IdTipoEntidadeComunicacao]
      ,[IdTipoEnvioComunicacao]
      ,[IdReferenciaComunicacaoTemplate]
    FROM ComunicacaoProcessada 

    WHERE IdComunicacaoProcessada > @Offset -- Assuming IDColumn is a unique identifier in SourceTable
    ORDER BY IdComunicacaoProcessada;

    -- Update @Offset to the last copied ID in this batch
    SET @Offset = (SELECT MAX(IdComunicacaoProcessada) FROM ComunicacaoProcessada_NEW (nolock));

    -- Get the number of rows copied in this iteration
    SET @RowCount = @@ROWCOUNT;
    if @RowCount > 10000
	    break;
     WAITFOR DELAY '00:00:00:010'; -- 10 milisegundos
END;
SET IDENTITY_INSERT ComunicacaoProcessada_NEW OFF



select * from ComunicacaoProcessada_NEW
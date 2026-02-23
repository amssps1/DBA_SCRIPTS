-- JOB - Limpeza Tabelas Histórico
USE IDH

go
--set datformat DMY

-- Declaração de Meses por Tabela
DECLARE @i_COF_CampanhasAutomaticasDetalhe INT = -30;

DECLARE @Deleted_Rows INT;

SET @Deleted_Rows = 1;
 WHILE (@Deleted_Rows > 0)
   BEGIN
    BEGIN TRANSACTION
    -- Delete some small number of rows at a time
      DELETE TOP (500000)  COF_CampanhasAutomaticasDetalhe 
      WHERE createddate > '23-10-2024'

      SET @Deleted_Rows = @@ROWCOUNT;
     COMMIT TRANSACTION
	PRINT @Deleted_Rows
	IF @Deleted_Rows < 100
	    BREAK;	
    waitfor DELAY '00:00:04.000'
 END


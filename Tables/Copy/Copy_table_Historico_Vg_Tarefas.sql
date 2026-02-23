set nocount on;

DECLARE @BatchSize INT = 25000; -- Number of records per batch
DECLARE @Offset INT = 0;       -- Starting point for each batch
DECLARE @RowCount INT = 1;     -- Number of rows copied in the last batch

WHILE @RowCount > 0
BEGIN
   BEGIN TRAN
    -- Copy a batch of records from SourceTable to CloneTable
    INSERT INTO [dbo].[VG_Tarefas_Historico]
            ([IDTarefas]
           ,[IDCarteiraDossier]
           ,[IDProcesso]
           ,[IDEstadoTarefa]
           ,[IDTipoTarefa]
           ,[IDContactos]
           ,[IDMotivos]
           ,[IDAgendamentos]
           ,[IDOrigemChamadas]
           ,[Prioridade]
           ,[DataCriacao]
           ,[DataFim]
           ,[NumeroDossier]
           ,[OWNERUSER]
           ,[ENDEDBY]
           ,[CriacaoAutomatica]
           ,[TerminoAutomatico]
           ,[PequenaDescricao]
           ,[DescricaoLonga]
           ,[DataUltimoEstado]
           ,[TipologiaTarefa]
           ,[CreatedDate]
           ,[CreatedByUser]
           ,[UpdatedDate]
           ,[UpdatedByUser]
           ,[NrTratamentos]
           ,[IDFinalizacaoTarefa]
           ,[IDActividade]
           ,[IDAlvo]
           ,[IDRequisitante]
           ,[IDEquipaExecutante]
           ,[IDUserAtribuido]
           ,[Alvo]
           ,[DataAgendamento]
           ,[ObsTarefa]
           ,[TarefaValidada]) 
    SELECT TOP (@BatchSize) 	 [IDTarefas]
          ,[IDCarteiraDossier]
           ,[IDProcesso]
           ,[IDEstadoTarefa]
           ,[IDTipoTarefa]
           ,[IDContactos]
           ,[IDMotivos]
           ,[IDAgendamentos]
           ,[IDOrigemChamadas]
           ,[Prioridade]
           ,[DataCriacao]
           ,[DataFim]
           ,[NumeroDossier]
           ,[OWNERUSER]
           ,[ENDEDBY]
           ,[CriacaoAutomatica]
           ,[TerminoAutomatico]
           ,[PequenaDescricao]
           ,[DescricaoLonga]
           ,[DataUltimoEstado]
           ,[TipologiaTarefa]
           ,[CreatedDate]
           ,[CreatedByUser]
           ,[UpdatedDate]
           ,[UpdatedByUser]
           ,[NrTratamentos]
           ,[IDFinalizacaoTarefa]
           ,[IDActividade]
           ,[IDAlvo]
           ,[IDRequisitante]
           ,[IDEquipaExecutante]
           ,[IDUserAtribuido]
           ,[Alvo]
           ,[DataAgendamento]
           ,[ObsTarefa]
           ,[TarefaValidada] 
    FROM VG_Tarefas V (nolock) 

    WHERE V.DataCriacao < '01-01-2021' and V.IDTarefas > @Offset
    ORDER BY IDTarefas;

	SET @RowCount = @@ROWCOUNT;
	PRINT @RowCount
    if @RowCount < 1
	    break;
	COMMIT
    -- Update @Offset to the last copied ID in this batch
    SET @Offset = (SELECT MAX(IDTarefas) FROM VG_Tarefas_Historico (nolock));
	PRINT @Offset
    -- Get the number of rows copied in this iteration
    

     WAITFOR DELAY '00:00:00:010'; -- 10 milisegundos
END;



--select * from VG_Tarefas 

--    WHERE DataCriacao < '01-01-2021' 
 -- select * from [VG_Tarefas]
 --ALTER TABLE VG_Tarefas_Historico NOCHECK CONSTRAINT all

 --truncate table [VG_Tarefas_Historico]



 --select * from VG_Tarefas_Historico order by IDTarefas
  --select count(*) from VG_Tarefas_Historico (nolock)
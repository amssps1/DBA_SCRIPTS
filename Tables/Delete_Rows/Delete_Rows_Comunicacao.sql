select cp.IdComunicacaoProcessada
into #teste
from ComunicacaoProcessada cp 
where cp.IdTipoEntidadeComunicacao = 1
and not exists(select 1 from ComunicacaoProcessadaProcesso cpp where cpp.IdComunicacaoProcessada = cp.IdComunicacaoProcessada)

delete from ComunicacaoAutomatica
where IdComunicacaoProcessada in(select IdComunicacaoProcessada from #teste)

delete from ComunicacaoProcessada
where IdComunicacaoProcessada in(select IdComunicacaoProcessada from #teste) 




USE Comunicacoes

go

DECLARE @Deleted_Rows INT;

SET @Deleted_Rows = 1;
 WHILE (@Deleted_Rows > 0)
   BEGIN
    BEGIN TRANSACTION
	
   	delete  from ComunicacaoProcessada where IdComunicacaoProcessada in (select top 5000 IdComunicacaoProcessada from ComunicacaoProcessada (nolock) where IdTipoEntidadeComunicacao = 1 
		and not exists (select 1 from ComunicacaoProcessadaProcesso where IdComunicacaoProcessada = ComunicacaoProcessada.IdComunicacaoProcessada) )


      SET @Deleted_Rows = @@ROWCOUNT;
     COMMIT TRANSACTION
	PRINT @Deleted_Rows
	IF @Deleted_Rows < 500
	    BREAK;	
    waitfor DELAY '00:00:00.200'
 END

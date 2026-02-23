-- JOB - Limpeza Tabelas Histórico
Begin

set nocount on

DECLARE @i_Deleted_VG_LarRecuperacaoHistorico  INT=0
DECLARE @i_Deleted_COF_BaseRiscoDAH_Historico  INT=0
DECLARE @i_Deleted_TG_ActividadeParametrizadaInfo  INT=0
DECLARE @i_Deleted_importacaocobrancashistorico  INT=0
DECLARE @i_Deleted_COM_ComunicacaoLog INT=0


--

DECLARE @iCount_Deleted_importacaocobrancashistorico  INT=0
DECLARE @importacaocobrancashistorico_Meses INT = -12;
DECLARE @iCount_Deleted_TG_ActividadeParametrizadaInfo  INT=0
DECLARE @iTG_ActividadeParametrizadaInfo_Meses INT = -12;


 DECLARE
    @TableHead VARCHAR(1000),
    @TableTail VARCHAR(1000)

-- Contadores Gerais
DECLARE @iCount_Deleted_VG_LarRecuperacaoHistorico  INT=0
DECLARE @iCount_Deleted_COF_BaseRiscoDAH_Historico  INT=0

-- Declaração de Meses por Tabela
DECLARE @iVG_LarRecuperacaoHistorico_Meses INT = -12;
DECLARE @iCOF_BaseRiscoDAH_Historico_Meses INT = -3;

DECLARE @iCount_Deleted_COM_ComunicacaoLog  INT=0
-- Declaração de Meses por Tabela
DECLARE @i_COM_ComunicacaoLog_Dias INT = -30;



DECLARE @Deleted_Rows INT;



SET @Deleted_Rows = 1;
 WHILE (@Deleted_Rows > 0)
   BEGIN
    BEGIN TRANSACTION
    -- Delete some small number of rows at a time
      DELETE TOP (100000)  idh.dbo.VG_LarRecuperacaoHistorico 
      WHERE createddate<DATEADD(MONTH, @iVG_LarRecuperacaoHistorico_Meses,GETDATE())

      SET @Deleted_Rows = @@ROWCOUNT;
      SET @iCount_Deleted_VG_LarRecuperacaoHistorico  = @iCount_Deleted_VG_LarRecuperacaoHistorico+ @Deleted_Rows;
      COMMIT TRANSACTION
      PRINT @Deleted_Rows
      IF @Deleted_Rows < 500
	    begin
	      SET @i_Deleted_VG_LarRecuperacaoHistorico=@iCount_Deleted_VG_LarRecuperacaoHistorico;
	      set @Deleted_Rows=0;
		end
      waitfor DELAY '00:00:00.200'

 END



 SET @Deleted_Rows = 1;
 WHILE (@Deleted_Rows > 0)
   BEGIN
    BEGIN TRANSACTION
    -- Delete some small number of rows at a time
      DELETE TOP (100000)  idh.dbo.COF_BaseRiscoDAH_Historico 
      WHERE createddate<DATEADD(MONTH,@iCOF_BaseRiscoDAH_Historico_Meses ,GETDATE())

    SET @Deleted_Rows = @@ROWCOUNT;
	SET @iCount_Deleted_COF_BaseRiscoDAH_Historico  = @iCount_Deleted_COF_BaseRiscoDAH_Historico + @Deleted_Rows;
	
	COMMIT TRANSACTION
	PRINT @Deleted_Rows
	IF @Deleted_Rows < 500
	 begin
	    SET @i_Deleted_COF_BaseRiscoDAH_Historico=@iCount_Deleted_COF_BaseRiscoDAH_Historico;
	    set @Deleted_Rows=0;
     end
    waitfor DELAY '00:00:00.200'
 END







SET @Deleted_Rows = 1;
 WHILE (@Deleted_Rows > 0)
   BEGIN
    BEGIN TRANSACTION
    -- Delete some small number of rows at a time
      DELETE TOP (100000)  idh.dbo.TG_ActividadeParametrizadaInfo 
      WHERE updateddate<DATEADD(MONTH, @iTG_ActividadeParametrizadaInfo_Meses,GETDATE())

    SET @Deleted_Rows = @@ROWCOUNT;
	SET @iCount_Deleted_TG_ActividadeParametrizadaInfo  =@iCount_Deleted_TG_ActividadeParametrizadaInfo + @Deleted_Rows;
	
	COMMIT TRANSACTION
	PRINT @Deleted_Rows
	IF @Deleted_Rows < 500
	begin
	    SET @i_Deleted_TG_ActividadeParametrizadaInfo=@iCount_Deleted_TG_ActividadeParametrizadaInfo;
	    set @Deleted_Rows=0;
    end    
    waitfor DELAY '00:00:00.200'
 END
 




SET @Deleted_Rows = 1;
 WHILE (@Deleted_Rows > 0)
   BEGIN
    BEGIN TRANSACTION
    -- Delete some small number of rows at a time
      DELETE TOP (100000) cobrancasdah.dbo.importacaocobrancashistorico 
      WHERE updateddate <DATEADD(month,@importacaocobrancashistorico_Meses,getdate())

    SET @Deleted_Rows = @@ROWCOUNT;
	SET @iCount_Deleted_importacaocobrancashistorico  = @iCount_Deleted_importacaocobrancashistorico + @Deleted_Rows;
	
	COMMIT TRANSACTION
	PRINT @Deleted_Rows
	IF @Deleted_Rows < 500
	begin
	    SET @i_Deleted_importacaocobrancashistorico=@iCount_Deleted_importacaocobrancashistorico;
	     set @Deleted_Rows=0;
	end
    waitfor DELAY '00:00:00.200'
 END









SET @Deleted_Rows = 1;
 WHILE (@Deleted_Rows > 0)
   BEGIN
    BEGIN TRANSACTION
    -- Delete some small number of rows at a time
      DELETE TOP (10000)  idh.dbo.COM_ComunicacaoLog 
      WHERE date<DATEADD(DD, @i_COM_ComunicacaoLog_Dias,GETDATE())

      SET @Deleted_Rows = @@ROWCOUNT;
	  SET @iCount_Deleted_COM_ComunicacaoLog  = @iCount_Deleted_COM_ComunicacaoLog + @Deleted_Rows;
     COMMIT TRANSACTION
	PRINT @Deleted_Rows
	IF @Deleted_Rows < 500
	begin
	   SET @i_Deleted_COM_ComunicacaoLog=@iCount_Deleted_COM_ComunicacaoLog;
	    SET @Deleted_Rows = 0;
	end
    waitfor DELAY '00:00:00.500'
 END


DECLARE @p_body as nvarchar(max), @p_subject as nvarchar(100)

SET @p_subject = N'JOB - Limpeza de Tabelas de Historico'

SET @TableTail = '</table></body></html>' ;
SET @TableHead = '<html><head>' + '<style>'
    + 'td {border: solid black;border-width: 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font: 11px arial} '
    + '</style>' + '</head>' + '<body>' + 'Reporte Gerado em : ' + CONVERT(VARCHAR(50), GETDATE(), 106)  + '<br /><br /><br />'

SET @p_body = '<td bgcolor="#dedede"><b> Tabelas incluidos no Data Purge: </b></td>'   + CHAR(13) + '<br />';
SET @p_body = @p_body + 'VG_LarRecuperacaoHistorico: ';
SET @p_body = @p_body + '<td bgcolor="#dedede"><b>'+ CONVERT(varchar(10),@i_Deleted_VG_LarRecuperacaoHistorico) +  '</b></td>' + CHAR(13)  + '<br />';
SET @p_body = @p_body + 'COF_BaseRiscoDAH_Historico: ';
SET @p_body = @p_body + '<td bgcolor="#dedede"><b>'+ CONVERT(varchar(10),@i_Deleted_COF_BaseRiscoDAH_Historico) +  '</b></td>' + CHAR(13) + '<br />';
SET @p_body = @p_body + 'TG_ActividadeParametrizadaInfo: ';
SET @p_body = @p_body + '<td bgcolor="#dedede"><b>'+ CONVERT(varchar(10),@i_Deleted_TG_ActividadeParametrizadaInfo) +  '</b></td>' + CHAR(13) + '<br />';
SET @p_body = @p_body + 'importacaocobrancashistorico: ';
SET @p_body = @p_body + '<td bgcolor="#dedede"><b>'+ CONVERT(varchar(10),@i_Deleted_importacaocobrancashistorico) +  '</b></td>' + CHAR(13) + '<br />';
SET @p_body = @p_body + 'Com_ComunicacaoLog: ';
SET @p_body = @p_body + '<td bgcolor="#dedede"><b>'+ CONVERT(varchar(10),@i_Deleted_COM_ComunicacaoLog) +  '</b></td>' + CHAR(13) + + '<br />';



/*

               VG_LarRecuperacaoHistorico: ' + CONVERT(varchar(10),@i_Deleted_VG_LarRecuperacaoHistorico) + 
			   'COF_BaseRiscoDAH_Historico: ' + CONVERT(varchar(10),@i_Deleted_COF_BaseRiscoDAH_Historico) +
			   'TG_ActividadeParametrizadaInfo: ' + CONVERT(varchar(10),@i_Deleted_TG_ActividadeParametrizadaInfo) +
			   'importacaocobrancashistorico: ' + CONVERT(varchar(10),@i_Deleted_importacaocobrancashistorico) +
			   'Com_ComunicacaoLog : ' + CONVERT(varchar(10),@i_Deleted_COM_ComunicacaoLog) + '
			   
			   <b> Fim </b>.'
*/
			   
SELECT  @p_body = @TableHead + ISNULL(@p_body, '') + @TableTail

execute as login = 'sa'
exec msdb.dbo.sp_send_dbmail
		@profile_name='Administrator',
		@recipients='antonio.silva@cofidis.pt;joao.santos@cofidis.pt;elsa.costa@cofidis.pt',
		@body_format = 'HTML',
		@body = @p_body,
		 @subject = @p_subject


END
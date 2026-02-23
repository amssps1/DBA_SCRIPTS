

DECLARE @SourceDB NVARCHAR(100) = 'IDH';
DECLARE @TargetDB NVARCHAR(100) = 'Backup_Obsoletos';
DECLARE @TableName NVARCHAR(255);
DECLARE @SQL NVARCHAR(MAX);

-- Create a temporary table to store the list of tables to be copied
DECLARE @TableList TABLE (TableName NVARCHAR(255));

-- Insert the tables to be copied (Change table names accordingly)
INSERT INTO @TableList (TableName)
VALUES 
('OBSOLETA_VG_HistoricoCorrespondencia_BCK')
,('OBSOLETA_VG_LOG_LarRecuperacao_bck202105')
,('OBSOLETA_COF_RetornoAdeptra')
,('OBSOLETA_VG_Rel_LarDossierBck_nao_apagar')
,('OBSOLETA_VG_Rel_LarElementoBck_nao_apagar')
,('OBSOLETA_VG_LarRecuperacaoBck_nao_apagar')
,('OBSOLETA_VG_HistoricoAlteracaoManualFase')
,('OBSOLETA_COF_ProcessoRefADC')
,('OBSOLETA_COF_ProcessoRefADCPrevStep')
,('OBSOLETA_VG_HistoricoDossierSinistros_Capgemini')
,('OBSOLETA_VG_HistoricoSinistros')
,('OBSOLETA_VG_DossierSinistros_Capgemini')
,('OBSOLETA_cof_historicoparipersi_Bck1')
,('OBSOLETA_VG_EventoDistribuicao')
,('OBSOLETA_VG_LogWsLCM')
,('OBSOLETA_COF_HistoricoPariPersi2')
,('OBSOLETA_DLR_CampanhaModoMarcacao_Historico')
,('OBSOLETA_VG_DossierInvestigacao')
,('OBSOLETA_TTAR_Screen1')
,('OBSOLETA_TTAR_Screen2')
,('OBSOLETA_COF_PariPersi_Bck1')
,('OBSOLETA_TTAR_Screen3')
,('OBSOLETA_VG_DossierE')
,('OBSOLETA_DLR_ContactoCampanha')
,('OBSOLETA_vg_dossiersinistros_nsa')
,('OBSOLETA_TTAR_Screen4')
,('OBSOLETA_DLR_ContactoCampanhaEnjeu')
,('OBSOLETA_VG_HistoricoCartasEnviadas')
,('OBSOLETA_VG_HistoricoProcessamentoPagamentos')
,('OBSOLETA_DLR_ContactosTEMPDialer')
,('OBSOLETA_cof_processofacilidades_')
,('OBSOLETA_DLR_ContactoCampanhaDiaVencimento')
,('OBSOLETA_VG_HistoricoDevolucaoCheques')
,('OBSOLETA_VG_ChequeImpago')
,('OBSOLETA_COF_PersiRemovidos')
,('OBSOLETA_VG_TMP_PAG')
,('OBSOLETA_DLR_ContactoCampanhaAcordoFase1')
,('OBSOLETA_vg_tarefas_user_old')
,('OBSOLETA_VG_Carteira_BCK')
,('OBSOLETA_VG_ContadoresUtilizador')
,('OBSOLETA_DLR_ContactoCampanhaGlobalServico')
,('OBSOLETA_VG_HistoricoInvestigacao')
,('OBSOLETA_COF_PariPersi_Eliminados')
,('OBSOLETA_COF_ObjectivosDashBoard')
,('OBSOLETA_VG_EnvioSinistros')
,('OBSOLETA_VG_FamiliaProdutoUtilizador_bck')
,('OBSOLETA_VG_ProcessoTitularPRDConsulta')
,('OBSOLETA_TMP_SrecZero')
,('OBSOLETA_VG_CarteiraDossier_nsa')
,('OBSOLETA_VG_DossierCLD')
,('OBSOLETA_DLR_CampanhaModoMarcacao')
,('OBSOLETA_DLR_CampanhaCarteira')
,('OBSOLETA_DLR_ContactoCampanhaGlobal')
,('OBSOLETA_VG_SubTipoFase')
,('OBSOLETA_VG_ObjectivosCalculados')
,('OBSOLETA_tmp_todes')
,('OBSOLETA_TTAR_BACAgencia')
,('OBSOLETA_VG_FamiliaProdutoUtilizador')
,('OBSOLETA_TMP_srec_corrigir')
,('OBSOLETA_VG_ParametrosCartas')
,('OBSOLETA_VG_ConfiguracaoSMS')
,('OBSOLETA_VG_CarteiraFictica_Carteira')
,('OBSOLETA_TTAR_Bac')
,('OBSOLETA_VG_Telegramas')
,('OBSOLETA_COF_Objectivo')
,('OBSOLETA_TTAR_AgenciaFase')
,('OBSOLETA_VG_ReferenciasTipoTarefa')
,('OBSOLETA_VG_PerfilPreencheTarefa')
,('OBSOLETA_TTAR_FaseTransaccao')
,('OBSOLETA_VG_ConselheirosSobreendividamento_bck')
,('OBSOLETA_VG_ConselheirosSinistros_bck')
,('OBSOLETA_VG_Tranche')
,('OBSOLETA_TTAR_Agencia')
,('OBSOLETA_VG_HistoricoPRD')
,('OBSOLETA_VG_Operacoes')
,('OBSOLETA_TTAR_Transaccao')
,('OBSOLETA_TTAR_Fase')
,('OBSOLETA_DLR_ModoMarcacao')
,('OBSOLETA_VG_ConfigDadosTarefa')
,('OBSOLETA_VG_ConselheirosPlano_bck')
,('OBSOLETA_VG_DossierRetido')
,('OBSOLETA_VG_TipoConclusao')
,('OBSOLETA_VG_TipoCorrespondencia')
,('OBSOLETA_VG_TiposInvestigacao')
,('OBSOLETA_DLR_Process')
,('OBSOLETA_VG_HistoricoNaoCobravel')
,('OBSOLETA_COF_CalculoTodu')
,('OBSOLETA_COF_Objectivo_New')
,('OBSOLETA_COF_ObjectivoOwner')
,('OBSOLETA_COF_ObjectivosDashBoard_New')
,('OBSOLETA_COF_PariPersi_Log')
,('OBSOLETA_COF_ValorDashBoardObjectivo')
,('OBSOLETA_CV4_Circuitos')
,('OBSOLETA_DLR_ContactoCampanha_TELF_TMPFO')
,('OBSOLETA_DLR_ContactoCampanha_TMPFO')
,('OBSOLETA_DLR_LOG_ModosMarcacao')
,('OBSOLETA_DLR_Log_Preview')
,('OBSOLETA_DLR_UserSkillgroups')
,('OBSOLETA_TMP_Adeptra')
,('OBSOLETA_VG_Accao_Distribuicao_Simula')
,('OBSOLETA_VG_Agencias')
,('OBSOLETA_VG_CalcRegrasTipologiaLarLog_Simula')
,('OBSOLETA_VG_CarteiraDossier_Simula')
,('OBSOLETA_VG_CarteiraDossierGA')
,('OBSOLETA_VG_DossierCTXCaracteristicas')
,('OBSOLETA_VG_DossierRemovido')
,('OBSOLETA_VG_Dossierresolvido')
,('OBSOLETA_VG_Entidades')
,('OBSOLETA_VG_EnvioPRD')
,('OBSOLETA_VG_Estadodossier')
,('OBSOLETA_VG_FasesFechoContas')
,('OBSOLETA_VG_HistoricoAnulacaoSeguro')
,('OBSOLETA_VG_HistoricoBloqueioDesbloqueioConta')
,('OBSOLETA_VG_HistoricoJoker')
,('OBSOLETA_VG_Investigadores_bck')
,('OBSOLETA_VG_Juizo')
,('OBSOLETA_VG_JuizoLocalidade')
,('OBSOLETA_VG_LaresUtilizador')
,('OBSOLETA_VG_LarRecuperacao_Simula')
,('OBSOLETA_VG_LimitesTAN_PRD')
,('OBSOLETA_VG_Localidade')
,('OBSOLETA_VG_LOG_LarRecuperacao_Simula')
,('OBSOLETA_VG_MotivoRiscoExcluido')
,('OBSOLETA_VG_PosicaoCliente')
,('OBSOLETA_VG_RegraVariavelTipologia')
,('OBSOLETA_VG_Rel_LarDossier_Simula')
,('OBSOLETA_VG_REL_LarElemento_Simula')
,('OBSOLETA_VG_RulesDistrib')
,('OBSOLETA_VG_RulesDistribDetalhe')
,('OBSOLETA_VG_RulesDistribDossier_Simula')
,('OBSOLETA_VG_SimulacaoDistribuicaoContencioso')
,('OBSOLETA_VG_Tribunal')
,('OBSOLETA_VG_TribunalJuizo')
,('OBSOLETA_VG_TribunalLocalidade')
,('OBSOLETA_VG_UltimaExecucao')
,('OBSOLETA_VG_ZonaRecMorada');




-- Loop through each table in the list
DECLARE table_cursor CURSOR FOR
SELECT TableName FROM @TableList;

OPEN table_cursor;
FETCH NEXT FROM table_cursor INTO @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Copying table: ' + @TableName;

    -- Generate SQL to copy table structure and data
    SET @SQL = '
    USE [' + @TargetDB + '];
    IF NOT EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_NAME = ''' + @TableName + '''
    )
    BEGIN
        SELECT * INTO [' + @TargetDB + '].dbo.[' + @TableName + '] 
        FROM [' + @SourceDB + '].dbo.[' + @TableName + '];
    END
    ELSE
    BEGIN
        INSERT INTO [' + @TargetDB + '].dbo.[' + @TableName + ']
        SELECT * FROM [' + @SourceDB + '].dbo.[' + @TableName + '];
    END';

    -- Execute the generated SQL
    EXEC sp_executesql @SQL;

    -- Move to the next table
    FETCH NEXT FROM table_cursor INTO @TableName;
END;

-- Close and deallocate the cursor
CLOSE table_cursor;
DEALLOCATE table_cursor;

PRINT 'Table duplication completed!';





















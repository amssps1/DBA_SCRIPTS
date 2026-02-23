-- Transaction Logs
-- JOB que corre no periodo fora da Janela de Backup do FULL e é recorrente de 1 em 1 hora

--  Parâmetros
DECLARE @BackupHoje NVARCHAR(500)      = N'H:\Backup_Dia';
DECLARE @BackupRetencao NVARCHAR(500)  = N'H:\Backup_Retencao';
DECLARE @HojeData NVARCHAR(8)          = CONVERT(CHAR(8), GETDATE(), 112);         -- YYYYMMDD de hoje
DECLARE @OntemData NVARCHAR(8)         = CONVERT(CHAR(8), DATEADD(DAY, -1, GETDATE()), 112); -- YYYYMMDD de ontem
DECLARE @HoraData NVARCHAR(6)          = REPLACE(CONVERT(CHAR(8), GETDATE(), 108), ':', ''); -- HHMMSS
DECLARE @DateTimeSufixo NVARCHAR(20)   = @HojeData + '_' + @HoraData;

-- Ativar xp_cmdshell (se necessário)
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;


-- Variáveiss para o Cursor
DECLARE @DBName SYSNAME;
DECLARE @BackupFile NVARCHAR(1000);
DECLARE @SQL NVARCHAR(MAX);
DECLARE @LastLogBackup DATETIME;

-- Apaenas para as BDs com Full e as necessárias
DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE recovery_model_desc = 'FULL'
  AND name in('ASPState'
,'CobrancasDAH'
,'CofidisPayCore'
,'Cofinet'
,'Comunicacoes'
,'db_cofidis_dah'
,'DotNetNuke'
,'DSTI'
,'EngMetricsDB'
,'FileWatcher'
,'FM'
,'IDH'
,'LogginApp'
,'m-it2008'
,'Neptuno'
,'Nomia'
,'OutSystems'
,'OutSystems_Log2023'
,'Partner360'
,'PartnerBorderaux'
,'PaymentGateway'
,'QualContactCenter360'
,'RHInternalApp'
,'RSK_Score'
,'RUA'
,'RUP'
,'ScoreAuto'
,'ServiceGate'
,'TcontrolDAH'
,'Threatmetrix')
  AND state_desc = 'ONLINE'
  AND name NOT IN ('tempdb');

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DBName;

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        -- Verificar último backup de log
        SELECT TOP 1 @LastLogBackup = backup_finish_date
        FROM msdb.dbo.backupset
        WHERE database_name = @DBName AND type = 'L'
        ORDER BY backup_finish_date DESC;

        -- Só fazer backup se nunca feito ou passou > 1 hora
        IF @LastLogBackup IS NULL OR DATEDIFF(HOUR, @LastLogBackup, GETDATE()) >= 1
        BEGIN
            -- Cria subpasta no Backup_Dia para a base, se necessário
            DECLARE @CreateFolder NVARCHAR(500) = 
                'IF NOT EXIST "' + @BackupHoje + '\' + @DBName + '" mkdir "' + @BackupHoje + '\' + @DBName + '"';
            EXEC xp_cmdshell @CreateFolder;

            -- Caminho final do ficheiro
            SET @BackupFile = @BackupHoje + '\' + @DBName + '\' + @DBName + '_log_' + @DateTimeSufixo + '.trn';

            -- Comando de backup
            SET @SQL = '
                BACKUP LOG [' + @DBName + ']
                TO DISK = N''' + @BackupFile + '''
                WITH INIT, COMPRESSION, STATS = 5, NAME = N''Log Backup of ' + @DBName + '''';

            PRINT 'Backup do log: ' + @DBName + ' → ' + @BackupFile;
            EXEC sp_executesql @SQL;
        END
        ELSE
        BEGIN
            PRINT 'Ignorado: ' + @DBName + ' → backup recente já existe.';
        END
    END TRY
    BEGIN CATCH
        PRINT ' Erro no backup de log da base ' + @DBName + ': ' + ERROR_MESSAGE();
    END CATCH;

    FETCH NEXT FROM db_cursor INTO @DBName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

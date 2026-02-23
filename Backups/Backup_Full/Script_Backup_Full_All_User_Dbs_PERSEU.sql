/*=====================================================================
   SCRIPT DE BACKUP FULL + CÓPIA PARA RETENÇÃO
   Autor  : PERSEU
   Data   : 2025-06-24
======================================================================*/

-----------------------------------------------------------------------
-- 0. GARANTIR QUE EXISTE A TABELA DE LOG DE ERROS
-----------------------------------------------------------------------
IF DB_ID(N'dba_db') IS NULL
    RAISERROR ('A base de dados dba_db não existe.', 16, 1);

IF OBJECT_ID(N'dba_db.dbo.Backup_ErrosLog') IS NULL
BEGIN
    USE dba_db;
    CREATE TABLE dbo.Backup_ErrosLog
    (
        ID            INT IDENTITY(1,1) PRIMARY KEY,
        DatabaseName  SYSNAME        NOT NULL,
        BackupType    VARCHAR(10)    NOT NULL,
        ErroMensagem  NVARCHAR(MAX)  NOT NULL,
        DataErro      DATETIME       NOT NULL DEFAULT GETDATE(),
        BackupPath    NVARCHAR(500)  NULL,
        ScriptStep    VARCHAR(50)    NULL
    );
END
GO

-----------------------------------------------------------------------
-- 1. PARÂMETROS GERAIS E VARIÁVEIS
-----------------------------------------------------------------------
DECLARE @BackupHoje        VARCHAR(500) = 'M:\Backup_Dia';
DECLARE @BackupRetencao    VARCHAR(500) = 'M:\Backup_Retencao';

DECLARE @HojeData          CHAR(8)      = CONVERT(CHAR(8), GETDATE(), 112);          -- YYYYMMDD
DECLARE @OntemData         CHAR(8)      = CONVERT(CHAR(8), DATEADD(DAY, -1, GETDATE()), 112);
DECLARE @HoraData          CHAR(6)      = REPLACE(CONVERT(CHAR(8), GETDATE(), 108), ':', ''); -- HHMMSS
DECLARE @DateTimeSufixo    NVARCHAR(20) = @HojeData + '_' + @HoraData;

-- Activar xp_cmdshell (se já activo não faz mal)
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

-----------------------------------------------------------------------
-- 2. MOVER BACKUPS (ONTEM) PARA PASTA DE RETENÇÃO
-----------------------------------------------------------------------
IF OBJECT_ID('tempdb..#BakFiles') IS NOT NULL DROP TABLE #BakFiles;

CREATE TABLE #BakFiles
(
    FullPath  NVARCHAR(500),
    FileName  NVARCHAR(260)
);

-- listar todos os .bak e .trn do dia anterior
INSERT INTO #BakFiles (FullPath)
EXEC xp_cmdshell 'for /R "M:\Backup_Dia" %i in (*.bak *.trn) do @echo %i';

-- limpar nulos e extrair nome do ficheiro
DELETE FROM #BakFiles WHERE FullPath IS NULL;
UPDATE #BakFiles
SET FileName = REVERSE(LEFT(REVERSE(FullPath), CHARINDEX('\', REVERSE(FullPath)) - 1));

DECLARE 
    @FullPath    NVARCHAR(500),
    @FileName    NVARCHAR(260),
    @BaseName    NVARCHAR(128),
    @ArchiveDir  NVARCHAR(500),
    @CMD         NVARCHAR(1000);

DECLARE FileCursor CURSOR FAST_FORWARD FOR
    SELECT FullPath FROM #BakFiles
	-- copia todos os que lá estiverem
    --WHERE FullPath NOT LIKE '%' + @HojeData + '%';   -- ignora ficheiros de hoje

OPEN FileCursor;
FETCH NEXT FROM FileCursor INTO @FullPath;

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @CMD = N'EXEC sp_configure ''show advanced options'', 1;
			RECONFIGURE;
			EXEC sp_configure ''xp_cmdshell'', 1;
			RECONFIGURE';
		EXEC (@CMD);
    /* determinar nome do ficheiro */
    SET @FileName = REVERSE(LEFT(REVERSE(@FullPath), CHARINDEX('\', REVERSE(@FullPath)) - 1));

    /* descobrir nome da base */
    IF CHARINDEX('_full_', @FileName) > 0
        SET @BaseName = LEFT(@FileName, CHARINDEX('_full_', @FileName) - 1);
    ELSE IF CHARINDEX('_log_', @FileName) > 0
        SET @BaseName = LEFT(@FileName, CHARINDEX('_log_', @FileName) - 1);
    ELSE
        SET @BaseName = NULL;

    IF @BaseName IS NOT NULL
    BEGIN
        SET @ArchiveDir = @BackupRetencao + '\' + @OntemData + '\' + @BaseName;

        -- cria pasta destino, se necessário
        SET @CMD = 'IF NOT EXIST "' + @ArchiveDir + '" mkdir "' + @ArchiveDir + '"';
        EXEC xp_cmdshell @CMD;

        -- move ficheiro
        SET @CMD = 'move /Y "' + @FullPath + '" "' + @ArchiveDir + '\"';
        EXEC xp_cmdshell @CMD;
    END

    FETCH NEXT FROM FileCursor INTO @FullPath;
END

CLOSE FileCursor;
DEALLOCATE FileCursor;
DROP TABLE #BakFiles;


-----------------------------------------------------------------------
-- 3. BACKUP FULL DAS BASES (2 ficheiros)
-----------------------------------------------------------------------
DECLARE 
    @DBName          SYSNAME,
    @BackupFileBase  VARCHAR(2000),
    @SQL             NVARCHAR(MAX);

DECLARE db_cursor CURSOR FAST_FORWARD FOR
SELECT name
FROM sys.databases
--WHERE name NOT IN ('tempdb', 'ComunicacaoParceiros', 'ControlosPermanentes','db_cofidis_dah','db_cofidis_dah_interface','AdministracaoSistemas','db_cofidis_dah_interface_aux','db_cofidis_dah_transactionlog','ExtratoCofidis','dba_db','FactCofidis','Hangfire','Interfacesdah')
WHERE name NOT IN ('tempdb')

  --AND state_desc = 'ONLINE'
ORDER BY name;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DBName;

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
		SET @SQL = N'EXEC sp_configure ''show advanced options'', 1;
				RECONFIGURE;
				EXEC sp_configure ''xp_cmdshell'', 1;
				RECONFIGURE';
		 EXEC (@SQL);
        /* cria pasta da base se não existir */
        SET @CMD = 'IF NOT EXIST "' + @BackupHoje + '\' + @DBName + '" mkdir "' + @BackupHoje + '\' + @DBName + '"';
        EXEC xp_cmdshell @CMD;

        /* caminho base do backup */
        SET @BackupFileBase = @BackupHoje + '\' + @DBName + '\' + @DBName + '_full_' + @DateTimeSufixo;


        /* instrução de backup (2 ficheiros) */
        SET @SQL = N'
            BACKUP DATABASE [' + @DBName + N']
            TO 
                DISK = N''' + @BackupFileBase + N'_1.bak'',
                DISK = N''' + @BackupFileBase + N'_2.bak''
            WITH INIT, COMPRESSION, STATS = 5, NAME = N''Full Backup of ' + @DBName + N'''';

        --PRINT 'Backup FULL (2 ficheiros): ' + @DBName;
        EXEC (@SQL);
    END TRY
    BEGIN CATCH
        DECLARE @ErroMsg NVARCHAR(MAX) = ERROR_MESSAGE();

        INSERT INTO dba_db.dbo.Backup_ErrosLog
        (
            DatabaseName,
            BackupType,
            ErroMensagem,
            BackupPath,
            ScriptStep
        )
        VALUES
        (
            @DBName,
            'FULL',
            @ErroMsg,
            @BackupFileBase + '_1.bak',
            'Backup FULL'
        );

        PRINT 'Erro no backup da base ' + @DBName + ': ' + @ErroMsg;
    END CATCH;

    FETCH NEXT FROM db_cursor INTO @DBName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;



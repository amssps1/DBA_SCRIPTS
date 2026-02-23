-- PERSEU

--  Parâmetros
DECLARE @BackupHoje NVARCHAR(500)      = N'M:\Backup_Dia';
DECLARE @BackupRetencao NVARCHAR(500)  = N'M:\Backup_Retencao';
DECLARE @HojeData NVARCHAR(8)          = CONVERT(CHAR(8), GETDATE(), 112);         -- YYYYMMDD de hoje
DECLARE @OntemData NVARCHAR(8)         = CONVERT(CHAR(8), DATEADD(DAY, -1, GETDATE()), 112); -- YYYYMMDD de ontem
DECLARE @HoraData NVARCHAR(6)          = REPLACE(CONVERT(CHAR(8), GETDATE(), 108), ':', ''); -- HHMMSS
DECLARE @DateTimeSufixo NVARCHAR(20)   = @HojeData + '_' + @HoraData;

-- Ativar xp_cmdshell 
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

-- OVER BACKUPS ANTIGOS PARA RETENÇÃO

IF OBJECT_ID('tempdb..#BakFiles') IS NOT NULL DROP TABLE #BakFiles;

CREATE TABLE #BakFiles (
    FullPath NVARCHAR(500),
    FileName NVARCHAR(260)
);

-- Obter lista completa de .bak
INSERT INTO #BakFiles (FullPath)
EXEC xp_cmdshell 'for /R "M:\Backup_Dia" %i in (*.bak *.trn) do @echo %i';
--INSERT INTO #BakFiles (FullPath)
--EXEC xp_cmdshell 'dir /b /s "M:\Backup_Dia\*.bak"';

-- Limpar valores inválidos
--DELETE FROM #BakFiles WHERE FullPath IS NULL OR FullPath NOT LIKE '%.bak';
UPDATE #BakFiles SET FileName = REVERSE(LEFT(REVERSE(FullPath), CHARINDEX('\', REVERSE(FullPath)) - 1));
SELECT * FROM #BakFiles
-- Variáveis
DECLARE @FullPath NVARCHAR(500);
DECLARE @FileName NVARCHAR(260);
DECLARE @BaseName NVARCHAR(128);
DECLARE @ArchiveDir NVARCHAR(500);
DECLARE @CMD NVARCHAR(1000);

-- Processar apenas ficheiros que não são de hoje
DECLARE FileCursor CURSOR FOR
SELECT FullPath FROM #BakFiles
--WHERE FullPath NOT LIKE '%' + @HojeData + '%';

OPEN FileCursor;
FETCH NEXT FROM FileCursor INTO @FullPath;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Obter nome do ficheiro a partir do caminho completo
    IF CHARINDEX('\', REVERSE(@FullPath)) > 0
    BEGIN
        SET @FileName = REVERSE(LEFT(REVERSE(@FullPath), CHARINDEX('\', REVERSE(@FullPath)) - 1));
        PRINT @FileName;

        -- Extrair nome da base consoante tipo de ficheiro
        IF CHARINDEX('_full_', @FileName) > 0
            SET @BaseName = LEFT(@FileName, CHARINDEX('_full_', @FileName) - 1);
        ELSE IF CHARINDEX('_log_', @FileName) > 0
            SET @BaseName = LEFT(@FileName, CHARINDEX('_log_', @FileName) - 1);
        ELSE
            SET @BaseName = 'Desconheciada'; 

        --PRINT ISNULL(@BaseName, 'BaseName não identificado');

        -- Diretório destino: Retenção\YYYYMMDD\Base
        IF @BaseName IS NOT NULL
        BEGIN
            SET @ArchiveDir = @BackupRetencao + '\' + @OntemData + '\' + @BaseName;
            PRINT @ArchiveDir;

            -- Criar diretório
            SET @CMD = 'IF NOT EXIST "' + @ArchiveDir + '" mkdir "' + @ArchiveDir + '"';
            --PRINT @CMD;
            EXEC xp_cmdshell @CMD;

            -- Mover ficheiro
            SET @CMD = 'move /Y "' + @FullPath + '" "' + @ArchiveDir + '\"';
            --PRINT @CMD;
            EXEC xp_cmdshell @CMD;
        END
        ELSE
        BEGIN
            PRINT 'Erro: BaseName não foi identificado para o ficheiro ' + @FileName;
        END
    END
    ELSE
    BEGIN
        PRINT 'Erro: Caminho inválido em @FullPath = ' + ISNULL(@FullPath, '(NULL)');
    END

    FETCH NEXT FROM FileCursor INTO @FullPath;
END


CLOSE FileCursor;
DEALLOCATE FileCursor;
DROP TABLE #BakFiles;


-- 2. EFETUAR BACKUPS FULL DAS BASES (2 ficheiros)

DECLARE @DBName SYSNAME;
DECLARE @BackupFileBase VARCHAR(2000);
DECLARE @SQL NVARCHAR(MAX);


-- Cursor com excepção de BDs
DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE name NOT IN ('tempdb')
  AND state_desc = 'ONLINE'
  AND user_access_desc = 'MULTI_USER';

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DBName;

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        -- Criar folder
        SET @CMD = 'IF NOT EXIST "' + @BackupHoje + '\' + @DBName + '" mkdir "' + @BackupHoje + '\' + @DBName + '"';
        EXEC xp_cmdshell @CMD;
		PRINT @CMD

        SET @BackupFileBase = @BackupHoje + '\' + @DBName + '\' + @DBName + '_full_' + @DateTimeSufixo;
		PRINT @BackupFileBase


        -- Comando de backup com 2 ficheiros
        SET @SQL = '
            BACKUP DATABASE [' + @DBName + ']
            TO 
                DISK = N''' + @BackupFileBase + '_1.bak'',
                DISK = N''' + @BackupFileBase + '_2.bak''
            WITH INIT, COMPRESSION, STATS = 5, NAME = N''Full Backup of ' + @DBName + '''';

        PRINT 'Backup FULL (2 ficheiros): ' + @DBName;
        EXEC sp_executesql @SQL;
		--PRINT @SQL
    END TRY
    BEGIN CATCH
        PRINT 'Erro no backup da base ' + @DBName + ': ' + ERROR_MESSAGE();
    END CATCH;

    FETCH NEXT FROM db_cursor INTO @DBName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;



--  Parâmetros
DECLARE @BackupHoje NVARCHAR(500)      = N'H:\Backup_Dia';
DECLARE @BackupRetencao NVARCHAR(500)  = N'H:\Backup_Retencao';
DECLARE @HojeData NVARCHAR(8)          = CONVERT(CHAR(8), GETDATE(), 112);         -- YYYYMMDD de hoje
DECLARE @OntemData NVARCHAR(8)         = CONVERT(CHAR(8), DATEADD(DAY, -1, GETDATE()), 112); -- YYYYMMDD de ontem
DECLARE @HoraData NVARCHAR(6)          = REPLACE(CONVERT(CHAR(8), GETDATE(), 108), ':', ''); -- HHMMSS
DECLARE @DateTimeSufixo NVARCHAR(20)   = @HojeData + '_' + @HoraData;

-- ⚠️ Ativar xp_cmdshell (se necessário)
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

-- 1️⃣ MOVER BACKUPS ANTIGOS PARA RETENÇÃO

IF OBJECT_ID('tempdb..#BakFiles') IS NOT NULL DROP TABLE #BakFiles;

CREATE TABLE #BakFiles (
    FullPath NVARCHAR(500),
    FileName NVARCHAR(260)
);

-- Obter lista completa de .bak
INSERT INTO #BakFiles (FullPath)
EXEC xp_cmdshell 'dir /b /s "H:\Backup_Dia\*.bak"';

-- Limpar valores inválidos
DELETE FROM #BakFiles WHERE FullPath IS NULL OR FullPath NOT LIKE '%.bak';
UPDATE #BakFiles SET FileName = REVERSE(LEFT(REVERSE(FullPath), CHARINDEX('\', REVERSE(FullPath)) - 1));

-- Variáveis
DECLARE @FullPath NVARCHAR(500);
DECLARE @FileName NVARCHAR(260);
DECLARE @BaseName NVARCHAR(128);
DECLARE @ArchiveDir NVARCHAR(500);
DECLARE @CMD NVARCHAR(1000);

-- Processar apenas ficheiros que não são de hoje
DECLARE FileCursor CURSOR FOR
SELECT FullPath FROM #BakFiles
WHERE FullPath NOT LIKE '%' + @HojeData + '%';

OPEN FileCursor;
FETCH NEXT FROM FileCursor INTO @FullPath;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @FileName = REVERSE(LEFT(REVERSE(@FullPath), CHARINDEX('\', REVERSE(@FullPath)) - 1));

    IF CHARINDEX('_full_', @FileName) > 0
        SET @BaseName = LEFT(@FileName, CHARINDEX('_full_', @FileName) - 1);
    ELSE
        SET @BaseName = 'Desconhecida';

    -- Diretório destino: Retenção\YYYYMMDD (ontem)\Base
    SET @ArchiveDir = @BackupRetencao + '\' + @OntemData + '\' + @BaseName;

    -- Criar diretório
    SET @CMD = 'IF NOT EXIST "' + @ArchiveDir + '" mkdir "' + @ArchiveDir + '"';
    EXEC xp_cmdshell @CMD;

    -- Mover ficheiro
    SET @CMD = 'move /Y "' + @FullPath + '" "' + @ArchiveDir + '\\"';
    EXEC xp_cmdshell @CMD;

    FETCH NEXT FROM FileCursor INTO @FullPath;
END

CLOSE FileCursor;
DEALLOCATE FileCursor;
DROP TABLE #BakFiles;

-- 2️⃣ EFETUAR BACKUPS FULL PARA BASES ONLINE

DECLARE @DBName SYSNAME;
DECLARE @BackupFile NVARCHAR(1000);
DECLARE @SQL NVARCHAR(MAX);

DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE database_id > 4 AND state_desc = 'ONLINE' 
AND name NOT IN ('tempdb');


OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DBName;

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        -- Criar diretório da base
        SET @CMD = 'IF NOT EXIST "' + @BackupHoje + '\' + @DBName + '" mkdir "' + @BackupHoje + '\' + @DBName + '"';
        EXEC xp_cmdshell @CMD;

        -- Caminho do ficheiro de backup
        SET @BackupFile = @BackupHoje + '\' + @DBName + '\' + @DBName + '_full_' + @DateTimeSufixo + '.bak';

        -- Comando de backup
        SET @SQL = '
            BACKUP DATABASE [' + @DBName + ']
            TO DISK = N''' + @BackupFile + '''
            WITH INIT, COMPRESSION, STATS = 5, NAME = N''Full Backup of ' + @DBName + '''';

        PRINT '📦 Backup FULL: ' + @DBName + ' → ' + @BackupFile;
        EXEC sp_executesql @SQL;
    END TRY
    BEGIN CATCH
        PRINT '❌ Erro no backup da base ' + @DBName + ': ' + ERROR_MESSAGE();
    END CATCH;

    FETCH NEXT FROM db_cursor INTO @DBName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

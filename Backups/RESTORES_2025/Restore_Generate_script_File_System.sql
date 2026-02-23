-- Parâmetros
DECLARE @DatabaseName SYSNAME = 'MinhaBaseDeDados'
DECLARE @BackupPath NVARCHAR(4000) = 'H:\Backup_Restore'
DECLARE @TargetDataPath NVARCHAR(4000) = 'D:\SQLData\'  -- opcional
DECLARE @TargetLogPath  NVARCHAR(4000) = 'E:\SQLLogs\'  -- opcional

-- Tabelas temporárias
IF OBJECT_ID('tempdb..#BackupFiles') IS NOT NULL DROP TABLE #BackupFiles
CREATE TABLE #BackupFiles (
    BackupFile NVARCHAR(4000),
    BackupType CHAR(1),
    BackupStartDate DATETIME
)

-- Obter lista de ficheiros do diretório
INSERT INTO #BackupFiles (BackupFile)
EXEC xp_cmdshell 'dir /b /s "H:\Backup_Restore\*.bak"'

INSERT INTO #BackupFiles (BackupFile)
EXEC xp_cmdshell 'dir /b /s "H:\Backup_Restore\*.trn"'

-- Limpar linhas inválidas
DELETE FROM #BackupFiles WHERE BackupFile IS NULL OR BackupFile NOT LIKE '%.trn' AND BackupFile NOT LIKE '%.bak'

-- Adicionar tipo de backup e data
UPDATE #BackupFiles
SET BackupType = CASE 
                    WHEN BackupFile LIKE '%.bak' THEN 'D'
                    WHEN BackupFile LIKE '%.trn' THEN 'L'
                 END,
    BackupStartDate = TRY_CONVERT(DATETIME, 
        SUBSTRING(BackupFile, PATINDEX('%'+@DatabaseName+'_%', BackupFile) + LEN(@DatabaseName) + 1, 15),
        112)

-- Obter o FULL mais recente
DECLARE @FullBackupFile NVARCHAR(4000)
SELECT TOP 1 @FullBackupFile = BackupFile
FROM #BackupFiles
WHERE BackupType = 'D' AND BackupFile LIKE '%'+@DatabaseName+'%'
ORDER BY BackupStartDate DESC

IF @FullBackupFile IS NULL
BEGIN
    RAISERROR('Nenhum backup FULL encontrado para a base de dados %s.', 16, 1, @DatabaseName)
    RETURN
END

-- Obter TRNs posteriores ao FULL
DECLARE @FullDate DATETIME
SELECT @FullDate = BackupStartDate FROM #BackupFiles WHERE BackupFile = @FullBackupFile

DECLARE @LogList TABLE (BackupFile NVARCHAR(4000), BackupStartDate DATETIME)
INSERT INTO @LogList
SELECT BackupFile, BackupStartDate
FROM #BackupFiles
WHERE BackupType = 'L' AND BackupFile LIKE '%'+@DatabaseName+'%'
AND BackupStartDate > @FullDate
ORDER BY BackupStartDate

-- Obter ficheiros de dados/log da BD
DECLARE @DataFile NVARCHAR(4000), @LogFile NVARCHAR(4000)
SELECT TOP 1
    @DataFile = @TargetDataPath + @DatabaseName + '_Data.mdf',
    @LogFile = @TargetLogPath + @DatabaseName + '_Log.ldf'

-- Construir comando de RESTORE
DECLARE @SQL NVARCHAR(MAX) = ''
SET @SQL += 'RESTORE DATABASE [' + @DatabaseName + ']' + CHAR(13)
SET @SQL += 'FROM DISK = N''' + @FullBackupFile + '''' + CHAR(13)
SET @SQL += 'WITH MOVE ''' + @DatabaseName + ''' TO N''' + @DataFile + ''',' + CHAR(13)
SET @SQL += '     MOVE ''' + @DatabaseName + '_log'' TO N''' + @LogFile + ''',' + CHAR(13)
SET @SQL += '     NORECOVERY, REPLACE;' + CHAR(13)

-- Adicionar TRNs
DECLARE @LogBackupFile NVARCHAR(4000)
DECLARE log_cursor CURSOR FOR SELECT BackupFile FROM @LogList
OPEN log_cursor
FETCH NEXT FROM log_cursor INTO @LogBackupFile
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL += 'RESTORE LOG [' + @DatabaseName + ']' + CHAR(13)
    SET @SQL += 'FROM DISK = N''' + @LogBackupFile + '''' + CHAR(13)
    SET @SQL += 'WITH NORECOVERY;' + CHAR(13)
    FETCH NEXT FROM log_cursor INTO @LogBackupFile
END
CLOSE log_cursor
DEALLOCATE log_cursor

-- RESTORE COM RECOVERY
SET @SQL += 'RESTORE DATABASE [' + @DatabaseName + '] WITH RECOVERY;' + CHAR(13)

-- Exibir ou executar
PRINT '-- Script Gerado:'
PRINT @SQL

-- Opcional: descomentar para executar
-- EXEC (@SQL)

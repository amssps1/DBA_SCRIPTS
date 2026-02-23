-- Script para restaurar uma base de dados a partir de ficheiros .bak e .trn
-- Indicar apenas o nome da base e a localização dos ficheiros

DECLARE @DatabaseName SYSNAME = 'Outsystems';
DECLARE @BackupFolder NVARCHAR(4000) = 'H:\Backup_Dia\Outsystems';
DECLARE @TargetDataPath NVARCHAR(4000) = 'E:\Data\';
DECLARE @TargetLogPath  NVARCHAR(4000) = 'L:\Log\';

-- Tabelas temporárias para os ficheiros
IF OBJECT_ID('tempdb..#Files') IS NOT NULL DROP TABLE #Files;
CREATE TABLE #Files (NomeCompleto NVARCHAR(4000));

-- Listar ficheiros da pasta
DECLARE @cmd NVARCHAR(4000) = 'dir /b /s "' + @BackupFolder + '\*.bak" & dir /b /s "' + @BackupFolder + '\*.trn"';
INSERT INTO #Files EXEC xp_cmdshell @cmd;

-- Limpar valores nulos ou inválidos
DELETE FROM #Files WHERE NomeCompleto IS NULL OR NomeCompleto NOT LIKE '[A-Z]:\%';

-- Separar ficheiros FULL e LOG
DECLARE @FullBackups TABLE (NomeCompleto NVARCHAR(4000));
DECLARE @LogFiles TABLE (NomeCompleto NVARCHAR(4000));

-- Obter todos os .bak para RESTORE com múltiplos volumes
INSERT INTO @FullBackups
SELECT NomeCompleto FROM #Files WHERE NomeCompleto LIKE '%.bak' ORDER BY NomeCompleto;

-- Verificar ficheiros de log após o último FULL
DECLARE @LastFull NVARCHAR(4000);
SELECT TOP 1 @LastFull = NomeCompleto FROM @FullBackups ORDER BY NomeCompleto DESC;

INSERT INTO @LogFiles (NomeCompleto)
SELECT NomeCompleto FROM #Files WHERE NomeCompleto LIKE '%.trn' AND NomeCompleto > @LastFull;

IF NOT EXISTS (SELECT 1 FROM @FullBackups)
BEGIN
    RAISERROR('Nenhum ficheiro .bak encontrado.', 16, 1);
    RETURN;
END

-- Obter logical names do primeiro FULL
DECLARE @FirstFull NVARCHAR(4000);
SELECT TOP 1 @FirstFull = NomeCompleto FROM @FullBackups ORDER BY NomeCompleto;

DECLARE @LogicalData SYSNAME = @DatabaseName;
DECLARE @LogicalLog SYSNAME = @DatabaseName + '_log';

BEGIN TRY
    CREATE TABLE #FL (LogicalName SYSNAME, PhysicalName SYSNAME, Type CHAR(1), FileGroupName SYSNAME, Size BIGINT, MaxSize BIGINT, FileId INT, CreateLSN NUMERIC(25,0), DropLSN NUMERIC(25,0), UniqueId UNIQUEIDENTIFIER, ReadOnlyLSN NUMERIC(25,0), ReadWriteLSN NUMERIC(25,0), BackupSizeInBytes BIGINT, SourceBlockSize INT, FileGroupId INT, LogGroupGUID UNIQUEIDENTIFIER, DifferentialBaseLSN NUMERIC(25,0), DifferentialBaseGUID UNIQUEIDENTIFIER, IsReadOnly BIT, IsPresent BIT, TDEThumbprint VARBINARY(32));
    INSERT INTO #FL EXEC('RESTORE FILELISTONLY FROM DISK = ''' + @FirstFull + '''');
    SELECT @LogicalData = LogicalName FROM #FL WHERE Type = 'D';
    SELECT @LogicalLog = LogicalName FROM #FL WHERE Type = 'L';
END TRY
BEGIN CATCH
    PRINT 'AVISO: Falha ao obter logical names. Serão usados nomes padrão.';
END CATCH

-- Construir comando RESTORE
DECLARE @SQL NVARCHAR(MAX) = '';
SET @SQL += 'RESTORE DATABASE [' + @DatabaseName + '] FROM ' + CHAR(13);

-- Adicionar todos os .bak
DECLARE @BakFile NVARCHAR(4000);
DECLARE bak_cursor CURSOR FOR SELECT NomeCompleto FROM @FullBackups ORDER BY NomeCompleto;
OPEN bak_cursor;
FETCH NEXT FROM bak_cursor INTO @BakFile;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL += 'DISK = N''' + @BakFile + ''',' + CHAR(13);
    FETCH NEXT FROM bak_cursor INTO @BakFile;
END
CLOSE bak_cursor;
DEALLOCATE bak_cursor;

-- Remover vírgula final e continuar
SET @SQL = LEFT(@SQL, LEN(@SQL) - 3) + CHAR(13);
SET @SQL += 'WITH MOVE N''' + @LogicalData + ''' TO N''' + @TargetDataPath + @DatabaseName + '.mdf'',' + CHAR(13);
SET @SQL += '     MOVE N''' + @LogicalLog + ''' TO N''' + @TargetLogPath + @DatabaseName + '_log.ldf'',' + CHAR(13);
SET @SQL += '     NORECOVERY, REPLACE, STATS = 5;' + CHAR(13);

-- Adicionar RESTORE LOGs
DECLARE @LogFile NVARCHAR(4000);
DECLARE log_cursor CURSOR FOR SELECT NomeCompleto FROM @LogFiles;
OPEN log_cursor;
FETCH NEXT FROM log_cursor INTO @LogFile;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL += 'RESTORE LOG [' + @DatabaseName + '] FROM DISK = N''' + @LogFile + ''' WITH NORECOVERY, STATS = 5;' + CHAR(13);
    FETCH NEXT FROM log_cursor INTO @LogFile;
END
CLOSE log_cursor;
DEALLOCATE log_cursor;

-- Finalizar com WITH RECOVERY
SET @SQL += 'RESTORE DATABASE [' + @DatabaseName + '] WITH RECOVERY, STATS = 5;' + CHAR(13);

-- Exibir script
PRINT '-- SCRIPT GERADO:';
PRINT @SQL;
-- EXEC(@SQL); -- Descomentar para executar

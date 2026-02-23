-- Parâmetros
DECLARE 
    @DatabaseName SYSNAME = 'MinhaBaseDeDados',
    @TargetDataPath NVARCHAR(4000) = 'D:\SQLData\',  -- destino do ficheiro MDF
    @TargetLogPath NVARCHAR(4000) = 'E:\SQLLogs\',   -- destino do ficheiro LDF
    @SQL NVARCHAR(MAX) = '',
    @FullBackupFile NVARCHAR(4000),
    @DataFileName SYSNAME,
    @LogFileName SYSNAME,
    @FullBackupStart DATETIME;

-- Obter o último FULL backup da base
SELECT TOP 1
    @FullBackupFile = mf.physical_device_name,
    @FullBackupStart = b.backup_start_date,
    @DataFileName = b.database_name,
    @LogFileName = b.database_name + '_log'
FROM msdb.dbo.backupset b
INNER JOIN msdb.dbo.backupmediafamily mf ON b.media_set_id = mf.media_set_id
WHERE b.database_name = @DatabaseName
  AND b.type = 'D' -- FULL
ORDER BY b.backup_start_date DESC;

IF @FullBackupFile IS NULL
BEGIN
    RAISERROR('Nenhum backup FULL encontrado para a base de dados %s.', 16, 1, @DatabaseName)
    RETURN
END

-- Obter TRN backups posteriores
DECLARE @LogBackups TABLE (
    BackupFile NVARCHAR(4000),
    BackupStartDate DATETIME
)

INSERT INTO @LogBackups (BackupFile, BackupStartDate)
SELECT mf.physical_device_name, b.backup_start_date
FROM msdb.dbo.backupset b
INNER JOIN msdb.dbo.backupmediafamily mf ON b.media_set_id = mf.media_set_id
WHERE b.database_name = @DatabaseName
  AND b.type = 'L'
  AND b.backup_start_date > @FullBackupStart
ORDER BY b.backup_start_date

-- Gerar RESTORE FULL
SET @SQL += '-- RESTORE da base de dados ' + @DatabaseName + ' para uma nova instância' + CHAR(13)
SET @SQL += 'RESTORE DATABASE [' + @DatabaseName + ']' + CHAR(13)
SET @SQL += 'FROM DISK = N''' + @FullBackupFile + '''' + CHAR(13)
SET @SQL += 'WITH MOVE N''' + @DataFileName + ''' TO N''' + @TargetDataPath + @DatabaseName + '.mdf'',' + CHAR(13)
SET @SQL += '     MOVE N''' + @LogFileName + ''' TO N''' + @TargetLogPath + @DatabaseName + '_log.ldf'',' + CHAR(13)
SET @SQL += '     NORECOVERY, REPLACE, STATS = 5;' + CHAR(13)

-- Adicionar RESTORE LOGs
DECLARE @LogFile NVARCHAR(4000)
DECLARE cur CURSOR FOR SELECT BackupFile FROM @LogBackups
OPEN cur
FETCH NEXT FROM cur INTO @LogFile
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL += 'RESTORE LOG [' + @DatabaseName + '] FROM DISK = N''' + @LogFile + ''' WITH NORECOVERY, STATS = 5;' + CHAR(13)
    FETCH NEXT FROM cur INTO @LogFile
END
CLOSE cur
DEALLOCATE cur

-- RESTORE com RECOVERY
SET @SQL += 'RESTORE DATABASE [' + @DatabaseName + '] WITH RECOVERY, STATS = 5;' + CHAR(13)

-- Exibir resultado
PRINT '-- Script de RESTORE para instância de destino:'
PRINT @SQL

-- Opcional: copiar para ficheiro ou guardar em tabela

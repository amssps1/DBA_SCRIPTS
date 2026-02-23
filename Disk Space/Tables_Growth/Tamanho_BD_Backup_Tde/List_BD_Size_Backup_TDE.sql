SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#DatabaseStats') IS NOT NULL
    DROP TABLE #DatabaseStats;

CREATE TABLE #DatabaseStats (
    DatabaseName SYSNAME,
    SizeMB DECIMAL(18,2),
    BackupSizeMB DECIMAL(18,2),
    CompressionRatio DECIMAL(10,2),
    IsTDEEnabled BIT
);

DECLARE @DatabaseName SYSNAME;
DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE database_id > 4 AND state_desc = 'ONLINE';  -- Exclui bases de sistema

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = '
        DECLARE @SizeMB DECIMAL(18,2);
        SELECT @SizeMB = SUM(size) * 8.0 / 1024
        FROM ' + QUOTENAME(@DatabaseName) + '.sys.master_files
        WHERE database_id = DB_ID(''' + @DatabaseName + ''');

        DECLARE @BackupSizeMB DECIMAL(18,2);
        SELECT TOP 1 @BackupSizeMB = backup_size / 1024.0 / 1024.0
        FROM 
		 msdb.dbo.backupmediafamily 
         INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
        WHERE database_name = ''' + @DatabaseName + ''' AND type = ''D'' AND msdb.dbo.backupmediafamily.physical_device_name LIKE ''(local)%''
        ORDER BY backup_finish_date DESC;

        DECLARE @TDE BIT;
        SELECT @TDE = is_encrypted FROM sys.databases WHERE name = ''' + @DatabaseName + '''; 

        INSERT INTO #DatabaseStats (DatabaseName, SizeMB, BackupSizeMB, CompressionRatio, IsTDEEnabled)
        VALUES (
            ''' + @DatabaseName + ''',
            @SizeMB,
            @BackupSizeMB,
            CASE WHEN @BackupSizeMB IS NOT NULL AND @BackupSizeMB > 0 THEN ROUND(@SizeMB / @BackupSizeMB, 2) ELSE NULL END,
            @TDE
        );';

    EXEC sp_executesql @SQL;

    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

-- Resultado final
SELECT 
    DatabaseName,
    SizeMB,
    BackupSizeMB,
    CompressionRatio,
    CASE WHEN IsTDEEnabled = 1 THEN 'Sim' ELSE 'Não' END AS TDE_Ativo
FROM #DatabaseStats
ORDER BY SizeMB DESC;

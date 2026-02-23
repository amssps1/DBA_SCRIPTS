USE master;
GO

/* ============================
   Parâmetros
   ============================ */
DECLARE @TargetLogSizeMB int = 1024;   -- tamanho desejado do log (MB) após o shrink
                                      -- ajusta conforme necessário

/* Bases de dados a incluir:
   - Exclui system DBs (db_id <= 4)
   - Exclui bases OFFLINE e READ_ONLY
*/
DECLARE @DbList TABLE (DbName sysname PRIMARY KEY);

INSERT INTO @DbList (DbName)
SELECT name
FROM sys.databases
WHERE database_id > 4             -- exclui master, tempdb, model, msdb
  AND state = 0                   -- ONLINE
  AND is_read_only = 0;           -- apenas bases de dados editáveis

DECLARE 
    @db  sysname,
    @sql nvarchar(max);

DECLARE curDB CURSOR LOCAL FAST_FORWARD FOR
    SELECT DbName FROM @DbList;

OPEN curDB;
FETCH NEXT FROM curDB INTO @db;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '========================================';
    PRINT 'Preparar SHRINK do log em database: ' + @db;
    PRINT '========================================';

    /* 
       IMPORTANTE (opcional mas recomendado):
       Se a BD estiver em FULL/BULK_LOGGED, deves fazer backup do log ANTES,
       por exemplo:

       BACKUP LOG [nomeBD] TO DISK = N''C:\Backups\LOG_nomeBD_YYYYMMDD.trn'' WITH INIT, COMPRESSION;

       Podes automatizar isto, mas aqui mantemos em comentário para não criar
       backups automaticamente sem controlo de localização.
    */

    SET @sql = N'
    USE ' + QUOTENAME(@db) + N';

    DECLARE @logFile sysname;
    DECLARE @BeforeMB decimal(18,2);
    DECLARE @AfterMB  decimal(18,2);

    -- Obter o ficheiro de LOG (assume 1 log file principal)
    SELECT 
        @logFile  = name,
        @BeforeMB = size * 8.0 / 1024.0   -- páginas (8 KB) -> MB
    FROM sys.database_files
    WHERE type_desc = N''LOG'';

    IF @logFile IS NOT NULL
    BEGIN
        PRINT ''=== Database: '' + DB_NAME() + '' ==='';
        PRINT ''    Log file: '' + @logFile;
        PRINT ''    Size before (MB): '' + CAST(@BeforeMB AS varchar(30));

        -- Ver transações ativas (apenas informativo)
        DBCC OPENTRAN WITH NO_INFOMSGS;

        -- SHRINK do transaction log
        DBCC SHRINKFILE(@logFile, ' + CAST(@TargetLogSizeMB AS nvarchar(10)) + N') WITH NO_INFOMSGS;

        -- Tamanho depois do SHRINK
        SELECT @AfterMB = size * 8.0 / 1024.0
        FROM sys.database_files
        WHERE name = @logFile;

        PRINT ''    Size after  (MB): '' + CAST(@AfterMB AS varchar(30));
        PRINT '''';
    END
    ELSE
    BEGIN
        PRINT ''[AVISO] Não foi encontrado ficheiro de LOG em '' + DB_NAME();
    END
    ';

    -- Opcional: ver o comando gerado
    --PRINT @sql;

    EXEC (@sql);

    FETCH NEXT FROM curDB INTO @db;
END

CLOSE curDB;
DEALLOCATE curDB;
GO

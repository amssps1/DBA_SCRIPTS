
DECLARE @DatabaseName SYSNAME;
DECLARE @LogicalLogName SYSNAME;
DECLARE @SQL NVARCHAR(MAX);

DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT name
FROM sys.databases
WHERE database_id > 4                          -- Exclui master, tempdb, model, msdb
  AND recovery_model_desc = 'SIMPLE'           -- Apenas bases em SIMPLE
  AND state_desc = 'ONLINE'                    -- Apenas bases ONLINE
  AND is_read_only = 0;                        -- Exclui bases read-only

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Obtem o nome lógico do ficheiro de log da base
    SELECT TOP 1 @LogicalLogName = name
    FROM sys.master_files
    WHERE database_id = DB_ID(@DatabaseName)
      AND type_desc = 'LOG';

    -- Constrói e executa o comando DBCC SHRINKFILE
    SET @SQL = '
    USE [' + @DatabaseName + '];
    DBCC SHRINKFILE (N''' + @LogicalLogName + ''', 1);
    PRINT ''✅ Shrink realizado em [' + @DatabaseName + '] - Log: ' + @LogicalLogName + ''';
    ';
    
    EXEC sp_executesql @SQL;

    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

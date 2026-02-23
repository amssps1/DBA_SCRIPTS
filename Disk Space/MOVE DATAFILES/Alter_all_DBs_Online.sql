DECLARE @DBName NVARCHAR(255);
DECLARE @SQL NVARCHAR(MAX);

-- Cursor to loop through all user databases
DECLARE db_cursor CURSOR FOR
SELECT name 
FROM sys.databases 
WHERE database_id > 4  -- Excludes system databases (master, tempdb, model, msdb)
AND state_desc <> 'ONLINE';  -- Select only databases that are not ONLINE

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DBName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Generate and execute the command to bring database online
    SET @SQL = 'ALTER DATABASE [' + @DBName + '] SET ONLINE;';
    PRINT 'Setting database ONLINE: ' + @DBName;
    EXEC sp_executesql @SQL;

    FETCH NEXT FROM db_cursor INTO @DBName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

PRINT 'All user databases are now ONLINE!';

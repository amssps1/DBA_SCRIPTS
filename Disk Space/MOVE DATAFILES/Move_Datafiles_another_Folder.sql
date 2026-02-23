-- Enable xp_cmdshell to allow file movement
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

DECLARE @DatabaseName NVARCHAR(255);
DECLARE @LogicalName NVARCHAR(255);
DECLARE @CurrentPath NVARCHAR(500);
DECLARE @NewPath NVARCHAR(500) = 'F:\MSSQL15.MSSQLSERVER\MSSQL\Data4\';  -- Change to your target folder
DECLARE @NewFile NVARCHAR(500);
DECLARE @SQL NVARCHAR(MAX);
DECLARE @MoveSQL VARCHAR(8000);
DECLARE @DBOfflineSQL NVARCHAR(MAX);
DECLARE @DBOnlineSQL NVARCHAR(MAX);

-- Cursor to loop through all user databases
DECLARE db_cursor CURSOR FOR
SELECT name FROM sys.databases WHERE database_id > 4 AND state_desc = 'ONLINE'
AND name NOT IN ('AdventureWorks2019');

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Processing database: ' + @DatabaseName;

    -- Step 1: Take Database Offline
    SET @DBOfflineSQL = 'ALTER DATABASE [' + @DatabaseName + '] SET OFFLINE WITH ROLLBACK IMMEDIATE;';
    PRINT @DBOfflineSQL;
    EXEC sp_executesql @DBOfflineSQL;

    -- Step 2: Generate ALTER DATABASE statements for all files
    DECLARE file_cursor CURSOR FOR
    SELECT name, physical_name 
    FROM sys.master_files 
    WHERE database_id = DB_ID(@DatabaseName);

    OPEN file_cursor;
    FETCH NEXT FROM file_cursor INTO @LogicalName, @CurrentPath;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @NewFile = @NewPath + RIGHT(@CurrentPath, CHARINDEX('\', REVERSE(@CurrentPath)) - 1);

        -- Update SQL Server metadata with new file path
        SET @SQL = 'ALTER DATABASE [' + @DatabaseName + '] MODIFY FILE (NAME = ' + QUOTENAME(@LogicalName) + ', FILENAME = ''' + @NewFile + ''');';
        PRINT @SQL;
        EXEC sp_executesql @SQL;

        -- Move the files physically using xp_cmdshell (Fixed syntax issue)
        SET @MoveSQL = 'cmd /c MOVE "' + @CurrentPath + '" "' + @NewFile + '"';
        PRINT @MoveSQL;  -- Debugging step to verify command
        EXEC xp_cmdshell @MoveSQL;  -- Fixed error here

        FETCH NEXT FROM file_cursor INTO @LogicalName, @CurrentPath;
    END

    CLOSE file_cursor;
    DEALLOCATE file_cursor;

    -- Step 3: Bring Database Back Online
    SET @DBOnlineSQL = 'ALTER DATABASE [' + @DatabaseName + '] SET ONLINE;';
    PRINT @DBOnlineSQL;
    EXEC sp_executesql @DBOnlineSQL;

    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

-- Disable xp_cmdshell after completion for security
EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE;
EXEC sp_configure 'show advanced options', 0;
RECONFIGURE;

PRINT 'All user database files have been moved and are now ONLINE.';

-- Script to enable Accelerated Database Recovery (ADR) for all user databases
DECLARE @DatabaseName NVARCHAR(128);
DECLARE @SQL NVARCHAR(MAX);

-- Cursor to loop through all user databases
DECLARE CursorDB CURSOR FOR
SELECT name
FROM sys.databases
WHERE database_id > 4 -- Exclude system databases (master, tempdb, model, msdb)
  AND state_desc = 'ONLINE';
--  AND name NOT IN ('CobrancasDAH'); -- Only include online databases

OPEN CursorDB;
FETCH NEXT FROM CursorDB INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN

	 SET @SQL= N'ALTER database ServiceGate set single_user with rollback IMMEDIATE;';
	 PRINT 'Enabling Database in Single User: ' + @DatabaseName;
     EXEC sp_executesql @SQL;
        
    -- Generate SQL to enable ADR for the current database
    SET @SQL = N'ALTER DATABASE ' + QUOTENAME(@DatabaseName) + N' SET ACCELERATED_DATABASE_RECOVERY = ON;';
	    -- Execute the SQL statement
    PRINT 'Enabling ADR for database: ' + @DatabaseName;
    EXEC sp_executesql @SQL;

	-- Multi_user
	 SET @SQL= N'ALTER database ServiceGate set MULTI_USER;';
	 PRINT 'Enabling Database in Multi User: ' + @DatabaseName;
     EXEC sp_executesql @SQL;

    FETCH NEXT FROM CursorDB INTO @DatabaseName;
END;

CLOSE CursorDB;
DEALLOCATE CursorDB;

PRINT 'ADR has been enabled for all user databases.';


-- Monitor

--monitor encryption progress
SELECT db_name(database_id), encryption_state, percent_complete, key_algorithm, key_length
FROM sys.dm_database_encryption_keys
GO    

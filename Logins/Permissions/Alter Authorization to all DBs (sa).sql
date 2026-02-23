DECLARE @dbName NVARCHAR(255);
DECLARE @sql NVARCHAR(MAX);

-- Cursor to iterate through all user databases
DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE state_desc = 'ONLINE'  -- Include only online databases
  AND name NOT IN ('master', 'model', 'msdb', 'tempdb'); -- Exclude system databases

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @dbName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Dynamic SQL to change the database owner to 'sa'
    SET @sql = 'ALTER AUTHORIZATION ON DATABASE::[' + @dbName + '] TO [sa];';
    PRINT @sql; -- Optional: Print the command for verification
    EXEC sp_executesql @sql;

    FETCH NEXT FROM db_cursor INTO @dbName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;
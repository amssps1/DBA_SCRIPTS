USE [DataExperimental_DICV];  -- Substitua pelo nome da sua base de dados
GO



DECLARE @UserName SYSNAME, @SQL NVARCHAR(MAX);

DECLARE orphan_users CURSOR FOR
SELECT dp.name
FROM sys.database_principals dp
LEFT JOIN sys.server_principals sp ON dp.sid = sp.sid
WHERE dp.type IN ('S', 'U')
  AND dp.authentication_type_desc <> 'DATABASE'
  AND sp.sid IS NULL
  AND dp.name NOT IN ('dbo', 'guest', 'INFORMATION_SCHEMA','sys');

OPEN orphan_users;
FETCH NEXT FROM orphan_users INTO @UserName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- 1. Reassign any schema owned by the orphan user to dbo
    DECLARE @SchemaName SYSNAME;
    DECLARE schema_cursor CURSOR FOR
    SELECT name
    FROM sys.schemas
    WHERE principal_id = USER_ID(@UserName);

    OPEN schema_cursor;
    FETCH NEXT FROM schema_cursor INTO @SchemaName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SQL = 'ALTER AUTHORIZATION ON SCHEMA::[' + @SchemaName + '] TO [dbo];';
        PRINT 'Transferring schema [' + @SchemaName + '] from user [' + @UserName + '] to dbo.';
        EXEC sp_executesql @SQL;
        FETCH NEXT FROM schema_cursor INTO @SchemaName;
    END

    CLOSE schema_cursor;
    DEALLOCATE schema_cursor;

    -- 2. Check if login exists
    IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @UserName)
    BEGIN
        -- Re-map orphan user to login
        SET @SQL = 'ALTER USER [' + @UserName + '] WITH LOGIN = [' + @UserName + '];';
        PRINT 'Re-mapped orphan user [' + @UserName + '].';
        EXEC sp_executesql @SQL;
    END
    ELSE
    BEGIN
        -- Drop the orphan user
        SET @SQL = 'DROP USER [' + @UserName + '];';
        PRINT 'Dropped orphan user [' + @UserName + '].';
        EXEC sp_executesql @SQL;
    END

    FETCH NEXT FROM orphan_users INTO @UserName;
END

CLOSE orphan_users;
DEALLOCATE orphan_users;

DECLARE @LoginName SYSNAME = 'usr_sql_dora4'; -- Substitua pelo login desejado
DECLARE @SQL NVARCHAR(MAX);
DECLARE @DatabaseName SYSNAME;

DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE database_id > 4 -- Exclui bases de sistema
  AND state_desc = 'ONLINE';

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = '
USE ' + QUOTENAME(@DatabaseName) + ';
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = N''' + @LoginName + '''
)
BEGIN
    CREATE USER [' + @LoginName + '] FOR LOGIN [' + @LoginName + '];
END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members rm
    JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
    JOIN sys.database_principals u ON rm.member_principal_id = u.principal_id
    WHERE r.name = ''db_owner'' AND u.name = N''' + @LoginName + '''
)
BEGIN
    EXEC sp_addrolemember N''db_owner'', N''' + @LoginName + ''';
END
';

    PRINT 'Granting db_owner in [' + @DatabaseName + ']...';
    EXEC sp_executesql @SQL;

    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

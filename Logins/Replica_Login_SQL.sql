SELECT 
    'CREATE LOGIN [' + name + '] WITH PASSWORD = ' + 
    CONVERT(NVARCHAR(MAX), password_hash, 1) + 
    ' HASHED, SID = ' + CONVERT(NVARCHAR(100), sid, 1) + 
    ', DEFAULT_DATABASE = [' + default_database_name + ']'
    + CASE WHEN is_policy_checked = 1 THEN ', CHECK_POLICY = ON' ELSE ', CHECK_POLICY = OFF' END
    + CASE WHEN is_expiration_checked = 1 THEN ', CHECK_EXPIRATION = ON' ELSE ', CHECK_EXPIRATION = OFF' END
    + ';' AS LoginScript
FROM sys.sql_logins
WHERE name = 'LinkSrv_Trinity';
IF OBJECT_ID('dbo.sp_ListDBPermissions') IS NOT NULL
    DROP PROCEDURE dbo.sp_ListDBPermissions;
GO

CREATE PROCEDURE dbo.sp_ListDBPermissions
    @DBName SYSNAME   -- Nome da base de dados a auditar
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(MAX);

    SET @sql = N'
    /* ============================================================
       Consolidado: Users + Roles + Permissões
       ============================================================ */
    SELECT ''01-User'' AS Section,
           ''CREATE USER ''+QUOTENAME(CAST(dp.name COLLATE DATABASE_DEFAULT AS NVARCHAR(4000)))+
           '' FOR LOGIN ''+QUOTENAME(CAST(dp.name COLLATE DATABASE_DEFAULT AS NVARCHAR(4000)))+'';'' AS ScriptCommand
    FROM [' + @DBName + '].sys.database_principals dp
    WHERE dp.type IN (''S'',''U'',''G'')
      AND dp.sid IS NOT NULL
      AND dp.name NOT IN (''sys'',''guest'',''INFORMATION_SCHEMA'',''dbo'')

    UNION ALL

    SELECT ''02-Role'' AS Section,
           ''CREATE ROLE ''+QUOTENAME(CAST(r.name COLLATE DATABASE_DEFAULT AS NVARCHAR(4000)))+'';'' AS ScriptCommand
    FROM [' + @DBName + '].sys.database_principals r
    WHERE r.type = ''R''
      AND r.name NOT IN (
            ''db_accessadmin'',''db_backupoperator'',''db_datareader'',''db_datawriter'',
            ''db_ddladmin'',''db_denydatareader'',''db_denydatawriter'',
            ''db_executor'',''db_owner'',''db_securityadmin'',''public''
      )

    UNION ALL

    SELECT ''03-RoleMember'' AS Section,
           ''ALTER ROLE ''+QUOTENAME(CAST(r.name COLLATE DATABASE_DEFAULT AS NVARCHAR(4000)))+
           '' ADD MEMBER ''+QUOTENAME(CAST(m.name COLLATE DATABASE_DEFAULT AS NVARCHAR(4000)))+'';'' AS ScriptCommand
    FROM [' + @DBName + '].sys.database_role_members drm
    JOIN [' + @DBName + '].sys.database_principals r ON drm.role_principal_id = r.principal_id
    JOIN [' + @DBName + '].sys.database_principals m ON drm.member_principal_id = m.principal_id
    WHERE r.type = ''R''
      AND r.name NOT IN (
            ''db_accessadmin'',''db_backupoperator'',''db_datareader'',''db_datawriter'',
            ''db_ddladmin'',''db_denydatareader'',''db_denydatawriter'',
            ''db_executor'',''db_owner'',''db_securityadmin'',''public''
      )

    UNION ALL

    SELECT ''04-Permission'' AS Section,
           CASE dp.state
                WHEN ''W'' THEN ''-- REVOKE ''+CAST(dp.permission_name COLLATE DATABASE_DEFAULT AS NVARCHAR(4000))
                            +'' ON ''+CASE WHEN dp.class_desc=''DATABASE'' 
                                           THEN ''DATABASE''
                                           ELSE QUOTENAME(CAST(OBJECT_NAME(dp.major_id,DB_ID(''' + @DBName + ''')) COLLATE DATABASE_DEFAULT AS NVARCHAR(4000))) END
                            +'' FROM ''+QUOTENAME(CAST(pr.name COLLATE DATABASE_DEFAULT AS NVARCHAR(4000)))+'';''
                WHEN ''G'' THEN ''GRANT ''+CAST(dp.permission_name COLLATE DATABASE_DEFAULT AS NVARCHAR(4000))
                            +'' ON ''+CASE WHEN dp.class_desc=''DATABASE''
                                           THEN ''DATABASE''
                                           ELSE QUOTENAME(CAST(OBJECT_NAME(dp.major_id,DB_ID(''' + @DBName + ''')) COLLATE DATABASE_DEFAULT AS NVARCHAR(4000))) END
                            +'' TO ''+QUOTENAME(CAST(pr.name COLLATE DATABASE_DEFAULT AS NVARCHAR(4000)))+'';''
                WHEN ''D'' THEN ''DENY ''+CAST(dp.permission_name COLLATE DATABASE_DEFAULT AS NVARCHAR(4000))
                            +'' ON ''+CASE WHEN dp.class_desc=''DATABASE''
                                           THEN ''DATABASE''
                                           ELSE QUOTENAME(CAST(OBJECT_NAME(dp.major_id,DB_ID(''' + @DBName + ''')) COLLATE DATABASE_DEFAULT AS NVARCHAR(4000))) END
                            +'' TO ''+QUOTENAME(CAST(pr.name COLLATE DATABASE_DEFAULT AS NVARCHAR(4000)))+'';''
           END AS ScriptCommand
    FROM [' + @DBName + '].sys.database_permissions dp
    JOIN [' + @DBName + '].sys.database_principals pr
         ON dp.grantee_principal_id = pr.principal_id
    WHERE dp.class_desc <> ''OBJECT_OR_COLUMN''

    ORDER BY Section, ScriptCommand;';

    EXEC sp_executesql @sql;
END;
GO

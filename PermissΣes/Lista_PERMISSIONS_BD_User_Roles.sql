-- Lista Permissões de uma BD

SET NOCOUNT ON;

;WITH P AS
(
    SELECT  
        dp.name                               AS UserName,
        dp.[type]                             AS PrincipalTypeCode,  -- S,U,G
        prm.state_desc                        AS PermissionState,
        prm.permission_name                   AS PermissionName,
        prm.class_desc                        AS PermissionScope,     -- DATABASE / OBJECT_OR_COLUMN / SCHEMA / ...
        SCHEMA_NAME(obj.schema_id)            AS ObjectSchema,
        obj.name                              AS ObjectName,
        obj.type_desc                         AS ObjectType,
        col.name                              AS ColumnName,
        prm.class,
        prm.major_id,
        prm.minor_id
    FROM sys.database_permissions AS prm
    INNER JOIN sys.database_principals AS dp
        ON prm.grantee_principal_id = dp.principal_id
    LEFT JOIN sys.objects AS obj
        ON prm.major_id = obj.object_id
    LEFT JOIN sys.columns AS col
        ON col.object_id = prm.major_id
       AND col.column_id = prm.minor_id
    WHERE dp.[type] IN ('S','U','G')
      AND dp.name NOT IN ('dbo','guest','INFORMATION_SCHEMA','sys')
),
R AS
(
    SELECT
        mbr.name                  AS UserName,
        mbr.[type]                AS PrincipalTypeCode,
        rol.name                  AS RoleName
    FROM sys.database_role_members AS drm
    INNER JOIN sys.database_principals AS rol
        ON rol.principal_id = drm.role_principal_id
    INNER JOIN sys.database_principals AS mbr
        ON mbr.principal_id = drm.member_principal_id
    WHERE mbr.[type] IN ('S','U','G')
      AND mbr.name NOT IN ('dbo','guest','INFORMATION_SCHEMA','sys')
)

-- Saída combinada: permissões + roles
SELECT 
    UserName,
    CASE PrincipalTypeCode WHEN 'S' THEN 'SQL_USER' WHEN 'U' THEN 'WINDOWS_USER' WHEN 'G' THEN 'WINDOWS_GROUP' ELSE PrincipalTypeCode END AS PrincipalType,
    PermissionState,
    PermissionName,
    PermissionScope,
    ObjectSchema,
    ObjectName,
    ObjectType,
    ColumnName,
    -- Script T-SQL das permissões
    CASE 
        WHEN PermissionScope = 'DATABASE' THEN
            PermissionState COLLATE DATABASE_DEFAULT + N' ' + 
            PermissionName COLLATE DATABASE_DEFAULT +
            N' TO ' + QUOTENAME(UserName COLLATE DATABASE_DEFAULT) +
            CASE WHEN PermissionState = 'GRANT_WITH_GRANT_OPTION' THEN N' WITH GRANT OPTION' ELSE N'' END

        WHEN PermissionScope = 'SCHEMA' THEN
            PermissionState COLLATE DATABASE_DEFAULT + N' ' + 
            PermissionName COLLATE DATABASE_DEFAULT +
            N' ON SCHEMA::' + QUOTENAME(SCHEMA_NAME(P.major_id) COLLATE DATABASE_DEFAULT) +
            N' TO ' + QUOTENAME(UserName COLLATE DATABASE_DEFAULT) +
            CASE WHEN PermissionState = 'GRANT_WITH_GRANT_OPTION' THEN N' WITH GRANT OPTION' ELSE N'' END

        WHEN PermissionScope = 'OBJECT_OR_COLUMN' AND P.minor_id = 0 THEN
            PermissionState COLLATE DATABASE_DEFAULT + N' ' + 
            PermissionName COLLATE DATABASE_DEFAULT +
            N' ON ' + QUOTENAME(ObjectSchema COLLATE DATABASE_DEFAULT) + N'.' + QUOTENAME(ObjectName COLLATE DATABASE_DEFAULT) +
            N' TO ' + QUOTENAME(UserName COLLATE DATABASE_DEFAULT) +
            CASE WHEN PermissionState = 'GRANT_WITH_GRANT_OPTION' THEN N' WITH GRANT OPTION' ELSE N'' END

        WHEN PermissionScope = 'OBJECT_OR_COLUMN' AND P.minor_id > 0 THEN
            PermissionState COLLATE DATABASE_DEFAULT + N' ' + 
            PermissionName COLLATE DATABASE_DEFAULT +
            N' ON OBJECT::' + QUOTENAME(ObjectSchema COLLATE DATABASE_DEFAULT) + N'.' + QUOTENAME(ObjectName COLLATE DATABASE_DEFAULT) +
            N' (' + QUOTENAME(ColumnName COLLATE DATABASE_DEFAULT) + N') TO ' + QUOTENAME(UserName COLLATE DATABASE_DEFAULT) +
            CASE WHEN PermissionState = 'GRANT_WITH_GRANT_OPTION' THEN N' WITH GRANT OPTION' ELSE N'' END

        ELSE
            N'-- Permissão não tratada: ' + COALESCE(PermissionScope, N'(NULL)') COLLATE DATABASE_DEFAULT
    END AS Script
FROM P
UNION ALL
SELECT
    R.UserName,
    CASE R.PrincipalTypeCode WHEN 'S' THEN 'SQL_USER' WHEN 'U' THEN 'WINDOWS_USER' WHEN 'G' THEN 'WINDOWS_GROUP' ELSE R.PrincipalTypeCode END AS PrincipalType,
    CAST(NULL AS nvarchar(60))   AS PermissionState,
    CAST(NULL AS nvarchar(128))  AS PermissionName,
    N'ROLE_MEMBERSHIP'           AS PermissionScope,
    CAST(NULL AS sysname)        AS ObjectSchema,
    CAST(NULL AS sysname)        AS ObjectName,
    CAST(NULL AS nvarchar(120))  AS ObjectType,
    CAST(NULL AS sysname)        AS ColumnName,
    N'ALTER ROLE ' + QUOTENAME(R.RoleName COLLATE DATABASE_DEFAULT) + 
    N' ADD MEMBER ' + QUOTENAME(R.UserName COLLATE DATABASE_DEFAULT) + N';' AS Script
FROM R
ORDER BY UserName, PermissionScope, ObjectSchema, ObjectName, ColumnName;

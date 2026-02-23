-- Substitua 'user_name' pelo nome do usuário que você deseja verificar
DECLARE @UserName NVARCHAR(128) = 'cdm\pimentre';

SELECT 
    princ.name AS [User],
    perm.state_desc AS [Permission State], 
    perm.permission_name AS [Permission],
    obj.name AS [Object Name], 
    obj.type_desc AS [Object Type]
FROM 
    sys.database_permissions AS perm
INNER JOIN 
    sys.database_principals AS princ ON perm.grantee_principal_id = princ.principal_id
LEFT JOIN 
    sys.objects AS obj ON perm.major_id = obj.object_id
WHERE 
    princ.name = @UserName
ORDER BY 
    [Object Name], [Permission];

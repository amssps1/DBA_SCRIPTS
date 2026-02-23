SELECT
  (
    dp.state_desc + ' ' +
    dp.permission_name collate latin1_general_cs_as + 
    ' ON ' + '[' + s.name + ']' + '.' + '[' + o.name + ']' +
    ' TO ' + '[' + dpr.name + ']'
  ) AS GRANT_STMT
FROM sys.database_permissions AS dp
  INNER JOIN sys.objects AS o ON dp.major_id=o.object_id
  INNER JOIN sys.schemas AS s ON o.schema_id = s.schema_id
  INNER JOIN sys.database_principals AS dpr ON dp.grantee_principal_id=dpr.principal_id
WHERE 1=1
    AND o.name IN ('RSK_LogODM')      -- Uncomment to filter to specific object(s)
--  AND dp.permission_name='EXECUTE'    -- Uncomment to filter to just the EXECUTEs
ORDER BY dpr.name


---


SELECT
state_desc + ' ' + permission_name +
' on ['+ ss.name + '].[' + so.name + ']
to [' + sdpr.name + ']'
COLLATE LATIN1_General_CI_AS as [Permissions T-SQL]
FROM SYS.DATABASE_PERMISSIONS AS sdp
JOIN sys.objects AS so
     ON sdp.major_id = so.OBJECT_ID
JOIN SYS.SCHEMAS AS ss
     ON so.SCHEMA_ID = ss.SCHEMA_ID
JOIN SYS.DATABASE_PRINCIPALS AS sdpr
     ON sdp.grantee_principal_id = sdpr.principal_id
where 1=1
  AND so.name = 'RSK_LogODM'

UNION

SELECT
state_desc + ' ' + permission_name +
' on Schema::['+ ss.name + ']
to [' + sdpr.name + ']'
COLLATE LATIN1_General_CI_AS as [Permissions T-SQL]
FROM SYS.DATABASE_PERMISSIONS AS sdp
JOIN SYS.SCHEMAS AS ss
     ON sdp.major_id = ss.SCHEMA_ID
     AND sdp.class_desc = 'Schema'
JOIN SYS.DATABASE_PRINCIPALS AS sdpr
     ON sdp.grantee_principal_id = sdpr.principal_id
where 1=1

order by [Permissions T-SQL]
GO
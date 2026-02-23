-- Substitui pelo nome da base de dados e da tabela que queres verificar
DECLARE @DatabaseName SYSNAME = 'Outsystems'
DECLARE @TableName SYSNAME = 'OSUSR_SVO_REQUESTAUTHORIZATION'

-- Obter o object_id da tabela
DECLARE @ObjectID INT = OBJECT_ID(QUOTENAME(@DatabaseName) + '.dbo.' + QUOTENAME(@TableName));

IF @ObjectID IS NULL
BEGIN
    RAISERROR('Tabela não encontrada: %s', 16, 1, @TableName);
    RETURN;
END

-- Lista os locks com os PIDs (session_id)
SELECT
    r.resource_type,
    r.resource_database_id,
    DB_NAME(r.resource_database_id) AS DatabaseName,
    OBJECT_NAME(p.object_id) AS TableName,
    r.request_mode,
    r.request_status,
    r.request_session_id AS SessionID,
    s.login_name,
    s.host_name,
    s.program_name
FROM sys.dm_tran_locks r
LEFT JOIN sys.dm_exec_sessions s ON r.request_session_id = s.session_id
LEFT JOIN sys.partitions p ON r.resource_associated_entity_id = p.hobt_id
WHERE r.resource_database_id = DB_ID(@DatabaseName)
  AND p.object_id = @ObjectID
ORDER BY r.request_session_id, r.resource_type;



--KILL 142
--KILL 903
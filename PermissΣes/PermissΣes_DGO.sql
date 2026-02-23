DECLARE @LoginName SYSNAME = 'COFIDIS2000\GRP_SQL_DGO';  -- Substitua pelo login pretendido
DECLARE @DbName SYSNAME;
DECLARE @SQL NVARCHAR(MAX);

-- 1. Criar o login no nível do servidor, se não existir
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @LoginName)
BEGIN
    PRINT 'A criar login no servidor...';
    EXEC('CREATE LOGIN [' + @LoginName + '] FROM WINDOWS;');
END

-- 2. Cursor pelas bases de dados de utilizador, online e não read-only
DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE database_id > 4              -- exclui bases de sistema
  AND state_desc = 'ONLINE'
  AND is_read_only = 0;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DbName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'A processar base de dados: ' + @DbName;

    -- Montar SQL dinâmico para executar no contexto da base
    SET @SQL = '
    USE [' + @DbName + '];

    IF NOT EXISTS (
        SELECT name FROM sys.database_principals WHERE name = N''' + @LoginName + '''
    )
    BEGIN
        CREATE USER [' + @LoginName + '] FOR LOGIN [' + @LoginName + '];
    END
    ELSE
    BEGIN
        ALTER USER [' + @LoginName + '] WITH LOGIN = [' + @LoginName + '];
    END;

    -- Garantir CONNECT
    GRANT CONNECT TO [' + @LoginName + '];

    -- Permissões de leitura: SELECT em todos os schemas
    DECLARE @SchemaName NVARCHAR(128);
    DECLARE schema_cursor CURSOR FOR
    SELECT name FROM sys.schemas
    WHERE name NOT IN (''guest'', ''INFORMATION_SCHEMA'', ''sys'');  -- excluir schemas do sistema

    OPEN schema_cursor;
    FETCH NEXT FROM schema_cursor INTO @SchemaName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC(''GRANT SELECT ON SCHEMA::['' + @SchemaName + ''] TO [' + @LoginName + '];'');
        FETCH NEXT FROM schema_cursor INTO @SchemaName;
    END

    CLOSE schema_cursor;
    DEALLOCATE schema_cursor;
    ';

    EXEC(@SQL);

    FETCH NEXT FROM db_cursor INTO @DbName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

PRINT 'Processo concluído.';

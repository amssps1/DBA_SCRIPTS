USE [master];
GO

-- Declaração de todas as variáveis necessárias
DECLARE @LoginName SYSNAME = 'cofidis2000\svc_deploy_dev';
DECLARE @SQL NVARCHAR(MAX);
DECLARE @DBName SYSNAME;
DECLARE @ParmDefinition NVARCHAR(500);
DECLARE @SSISDBExists BIT = 0;

-- Verificar se SSISDB existe
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'SSISDB' AND state_desc = 'ONLINE')
BEGIN
    SET @SSISDBExists = 1;
END

-- 1. Criar login no servidor se não existir
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @LoginName) 
BEGIN
    SET @SQL = N'CREATE LOGIN [' + @LoginName + '] FROM WINDOWS;';
    EXEC sp_executesql @SQL;
    PRINT 'Login criado: ' + @LoginName;
END

-- 2. Conceder permissões no nível do servidor
SET @SQL = N'GRANT CREATE ANY DATABASE TO [' + @LoginName + '];';
EXEC sp_executesql @SQL;

SET @SQL = N'GRANT VIEW ANY DEFINITION TO [' + @LoginName + '];';
EXEC sp_executesql @SQL;

-- 3. Processar cada banco de dados do usuário
DECLARE db_cursor CURSOR FOR
SELECT name FROM sys.databases 
WHERE state_desc = 'ONLINE'
AND name NOT IN ('master', 'tempdb', 'model', 'msdb', 'distribution', 'SSISDB','dba_db')
AND is_read_only = 0;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DBName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'A Processar a Base de Dados: ' + @DBName;
    
    -- Cria Login
    SET @SQL = N'USE [' + @DBName + ']; 
    IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @LoginNameParam)
        CREATE USER [' + @LoginName + '] FOR LOGIN [' + @LoginName + '];';
    
    SET @ParmDefinition = N'@LoginNameParam SYSNAME';
    
    BEGIN TRY
        EXEC sp_executesql @SQL, @ParmDefinition, @LoginNameParam = @LoginName;
    END TRY
    BEGIN CATCH
        PRINT 'Erro ao criar usuário no banco ' + @DBName + ': ' + ERROR_MESSAGE();
    END CATCH
    
    -- GRant de Permissões globais 
    SET @SQL = N'USE [' + @DBName + '];
    GRANT CONNECT TO [' + @LoginName + '];
    GRANT VIEW DEFINITION TO [' + @LoginName + '];
    GRANT CREATE TABLE TO [' + @LoginName + '];
    GRANT CREATE PROCEDURE TO [' + @LoginName + '];
    GRANT CREATE FUNCTION TO [' + @LoginName + '];
    GRANT CREATE VIEW TO [' + @LoginName + '];';
    
    BEGIN TRY
        EXEC sp_executesql @SQL;
    END TRY
    BEGIN CATCH
        PRINT 'Erro ao conceder permissões no banco ' + @DBName + ': ' + ERROR_MESSAGE();
    END CATCH
    
    -- Processar schemas e agtribuir as permissões pretendidas, como criação e alteração de objectos e os DML necessários sem o DELETE.
    SET @SQL = N'
    USE [' + @DBName + '];
    DECLARE @SchemaName NVARCHAR(128);
    DECLARE @DynamicSQL NVARCHAR(MAX);
    
    DECLARE SchemaCursor CURSOR FOR 
    SELECT name FROM sys.schemas 
    WHERE principal_id = 1';
    
    SET @SQL = @SQL + N'
    OPEN SchemaCursor;
    FETCH NEXT FROM SchemaCursor INTO @SchemaName;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @DynamicSQL = ''GRANT ALTER ON SCHEMA::'' + QUOTENAME(@SchemaName) + '' TO [' + @LoginName + ']'';
        EXEC sp_executesql @DynamicSQL;
        
        SET @DynamicSQL = ''GRANT SELECT, INSERT, UPDATE ON SCHEMA::'' + QUOTENAME(@SchemaName) + '' TO [' + @LoginName + ']'';
        EXEC sp_executesql @DynamicSQL;
        
        FETCH NEXT FROM SchemaCursor INTO @SchemaName;
    END
    
    CLOSE SchemaCursor;
    DEALLOCATE SchemaCursor;';
    
    BEGIN TRY
        EXEC sp_executesql @SQL;
    END TRY
    BEGIN CATCH
        PRINT 'Erro ao processar schemas no banco ' + @DBName + ': ' + ERROR_MESSAGE();
    END CATCH
    
    FETCH NEXT FROM db_cursor INTO @DBName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

-- 4. Processar MSDB separadamente , para ter acesso a adiciomnar jobs - temos que ver a parte do JOB como SA , fica pendente de ver esta parte
SET @SQL = N'
USE [msdb];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @LoginNameParam)
    CREATE USER [' + @LoginName + '] FOR LOGIN [' + @LoginName + '];

GRANT CONNECT TO [' + @LoginName + '];

IF IS_ROLEMEMBER(''SQLAgentOperatorRole'', @LoginNameParam) IS NULL
    EXEC sp_addrolemember ''SQLAgentOperatorRole'', @LoginNameParam;
    
IF IS_ROLEMEMBER(''db_ssisoperator'', @LoginNameParam) IS NULL
    EXEC sp_addrolemember ''db_ssisoperator'', @LoginNameParam;
    
IF IS_ROLEMEMBER(''db_ssisltduser'', @LoginNameParam) IS NULL
    EXEC sp_addrolemember ''db_ssisltduser'', @LoginNameParam;
    
IF IS_ROLEMEMBER(''db_datareader'', @LoginNameParam) IS NULL
    EXEC sp_addrolemember ''db_datareader'', @LoginNameParam;';

SET @ParmDefinition = N'@LoginNameParam SYSNAME';

BEGIN TRY
    EXEC sp_executesql @SQL, @ParmDefinition, @LoginNameParam = @LoginName;
END TRY
BEGIN CATCH
    PRINT 'Erro ao processar msdb: ' + ERROR_MESSAGE();
END CATCH

-- 5. Processar SSISDB separadamente - SOMENTE SE EXISTIR SS Catalog na instancia
IF @SSISDBExists = 1
BEGIN
    SET @SQL = N'
    USE [SSISDB];
    IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @LoginNameParam)
        DROP USER [' + @LoginName + '];

    IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @LoginNameParam)
        CREATE USER [' + @LoginName + '] FOR LOGIN [' + @LoginName + '];

    IF DATABASE_PRINCIPAL_ID(@LoginNameParam) IS NOT NULL 
    BEGIN
        GRANT CONNECT TO [' + @LoginName + '];
        ALTER ROLE [db_datareader] ADD MEMBER [' + @LoginName + '];
        ALTER ROLE [ssis_admin] ADD MEMBER [' + @LoginName + '];
    END';

    SET @ParmDefinition = N'@LoginNameParam SYSNAME';

    BEGIN TRY
        EXEC sp_executesql @SQL, @ParmDefinition, @LoginNameParam = @LoginName;
        PRINT 'Permissões no SSISDB configuradas para: ' + @LoginName;
    END TRY
    BEGIN CATCH
        PRINT 'Erro ao processar SSISDB: ' + ERROR_MESSAGE();
    END CATCH
END
ELSE
BEGIN
    PRINT 'SSISDB não existe nesta instancia. Sair config do SSISDB.';
END

PRINT 'Processamento concluído para o Deploy login: ' + @LoginName;
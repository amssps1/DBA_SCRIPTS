USE master;
GO

CREATE or ALTER TRIGGER trg_Block_SSMS_Logins
ON ALL SERVER
FOR LOGON
AS
BEGIN
    DECLARE @LoginName SYSNAME;
    DECLARE @ProgramName NVARCHAR(128);
    DECLARE @DatabaseName SYSNAME;

    SET @LoginName = ORIGINAL_LOGIN();

    SELECT @ProgramName = program_name
    FROM sys.dm_exec_sessions
    WHERE session_id = @@SPID;

    -- Bloquear se for via SSMS e login for o "login_bloqueado"
    IF @ProgramName LIKE 'Microsoft SQL Server Management Studio%' 
       AND (@LoginName = 'CC360' or @LoginName = 'cc360')
      
    BEGIN
        ROLLBACK;
    END
END;
GO

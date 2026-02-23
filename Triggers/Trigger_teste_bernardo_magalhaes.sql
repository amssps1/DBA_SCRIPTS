CREATE TABLE dbo.UpdateAuditLog (
    AuditID INT IDENTITY PRIMARY KEY,
    TableName SYSNAME,
    PrimaryKeyValue NVARCHAR(200),
    UpdateDate DATETIME DEFAULT GETDATE(),
    OriginalStatement NVARCHAR(MAX),
    HostName NVARCHAR(100),
    AppName NVARCHAR(100),
    LoginName NVARCHAR(100)
);
GO
------

CREATE OR ALTER TRIGGER tr_LogUpdateQuery
ON BillingData

AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQLText NVARCHAR(MAX);
    DECLARE @Table SYSNAME = 'BillingData';
    DECLARE @Host NVARCHAR(100) = HOST_NAME();
    DECLARE @App NVARCHAR(100) = APP_NAME();
    DECLARE @Login NVARCHAR(100) = ORIGINAL_LOGIN();

    -- Recupera o último SQL da sessão (com limitações!)
    SELECT @SQLText = text
    FROM sys.dm_exec_requests r
    CROSS APPLY sys.dm_exec_sql_text(r.sql_handle)
    WHERE r.session_id = @@SPID;

    -- Grava uma linha por cada row afetada
    INSERT INTO dbo.UpdateAuditLog (TableName, PrimaryKeyValue, OriginalStatement, HostName, AppName, LoginName)
    SELECT 
        @Table,
        CAST(i.ID AS NVARCHAR), -- ajuste se sua PK for outra
        @SQLText,
        @Host,
        @App,
        @Login
    FROM inserted i;
END;

-----
DROP TABLE IF EXISTS dbo.BillingData;
GO

CREATE TABLE [dbo].[BillingData]
(
[Id] [INT] NOT NULL IDENTITY(1, 1),
[DataBilling] [DATETIME] NULL,
[Estado] [INT] NULL
) ON [PRIMARY]
GO
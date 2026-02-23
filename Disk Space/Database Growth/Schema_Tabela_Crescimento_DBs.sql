USE dba_db;
GO

IF OBJECT_ID('dbo.Tabela_Crescimento_BDs','U') IS NULL
BEGIN
    CREATE TABLE dbo.Tabela_Crescimento_BDs
    (
        ServerName         SYSNAME        NOT NULL,
        DatabaseName       SYSNAME        NOT NULL,
        SnapshotMonth      DATE           NOT NULL,  -- sempre 1.º dia do mês (YYYY-MM-01)
        TotalGB            DECIMAL(19,2)  NOT NULL,
        DataGB             DECIMAL(19,2)  NOT NULL,
        LogGB              DECIMAL(19,2)  NOT NULL,
        GrowthGB           DECIMAL(19,2)  NULL,      -- face ao mês anterior
        GrowthPct          DECIMAL(9,2)   NULL,      -- face ao mês anterior
        CaptureUTC         DATETIME2(0)   NOT NULL    DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_Tabela_Crescimento_BDs PRIMARY KEY
            (ServerName, DatabaseName, SnapshotMonth)
    );
END
GO

-- (Opcional) Índice para relatórios por mês
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_Tabela_Crescimento_BDs_Month' 
      AND object_id = OBJECT_ID('dbo.Tabela_Crescimento_BDs'))
BEGIN
    CREATE INDEX IX_Tabela_Crescimento_BDs_Month 
        ON dbo.Tabela_Crescimento_BDs (SnapshotMonth);
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Snapshot_Tabela_Crescimento_BDs
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ThisServer SYSNAME = CAST(SERVERPROPERTY('MachineName') AS SYSNAME)
                         + COALESCE(N'\' + CAST(SERVERPROPERTY('InstanceName') AS SYSNAME), N'');
    DECLARE @SnapMonth  DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
    DECLARE @PrevMonth  DATE = DATEADD(MONTH, -1, @SnapMonth);

    ;WITH Sizes AS
    (
        SELECT
            d.name AS DatabaseName,
            TotalGB = CAST(SUM(mf.size) * 8.0 / 1024.0 / 1024.0 AS DECIMAL(19,2)),
            DataGB  = CAST(SUM(CASE WHEN mf.type = 0 THEN mf.size ELSE 0 END) * 8.0 / 1024.0 / 1024.0 AS DECIMAL(19,2)),
            LogGB   = CAST(SUM(CASE WHEN mf.type = 1 THEN mf.size ELSE 0 END) * 8.0 / 1024.0 / 1024.0 AS DECIMAL(19,2))
        FROM sys.databases d
        JOIN sys.master_files mf
             ON mf.database_id = d.database_id
        WHERE d.database_id > 4
          AND d.state = 0
        GROUP BY d.name
    ),
    WithPrev AS
    (
        SELECT 
            @ThisServer           AS ServerName,
            s.DatabaseName,
            @SnapMonth            AS SnapshotMonth,
            s.TotalGB,
            s.DataGB,
            s.LogGB,
            PrevTotalGB = p.TotalGB
        FROM Sizes s
        OUTER APPLY
        (
            SELECT ms.TotalGB
            FROM dbo.Tabela_Crescimento_BDs ms
            WHERE ms.ServerName   = @ThisServer
              AND ms.DatabaseName = s.DatabaseName
              AND ms.SnapshotMonth= @PrevMonth
        ) p
    )
    MERGE dbo.Tabela_Crescimento_BDs AS tgt
    USING
    (
        SELECT
            ServerName,
            DatabaseName,
            SnapshotMonth,
            TotalGB,
            DataGB,
            LogGB,
            GrowthGB = CASE WHEN PrevTotalGB IS NULL THEN NULL
                            ELSE CAST(TotalGB - PrevTotalGB AS DECIMAL(19,2)) END,
            GrowthPct = CASE WHEN PrevTotalGB IS NULL OR PrevTotalGB = 0 THEN NULL
                             ELSE CAST( (TotalGB - PrevTotalGB) / PrevTotalGB * 100.0 AS DECIMAL(9,2)) END
        FROM WithPrev
    ) AS src
      ON (tgt.ServerName = src.ServerName
      AND tgt.DatabaseName = src.DatabaseName
      AND tgt.SnapshotMonth = src.SnapshotMonth)
    WHEN MATCHED THEN
        UPDATE SET
            tgt.TotalGB   = src.TotalGB,
            tgt.DataGB    = src.DataGB,
            tgt.LogGB     = src.LogGB,
            tgt.GrowthGB  = src.GrowthGB,
            tgt.GrowthPct = src.GrowthPct,
            tgt.CaptureUTC= SYSUTCDATETIME()
    WHEN NOT MATCHED THEN
        INSERT (ServerName, DatabaseName, SnapshotMonth, TotalGB, DataGB, LogGB, GrowthGB, GrowthPct)
        VALUES (src.ServerName, src.DatabaseName, src.SnapshotMonth, src.TotalGB, src.DataGB, src.LogGB, src.GrowthGB, src.GrowthPct);
END
GO



--exec usp_Snapshot_Tabela_Crescimento_BDs
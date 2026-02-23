CREATE OR ALTER VIEW dbo.vw_Tabela_Crescimento_BDs_UltimoMes
AS
WITH Ultimo AS
(
    SELECT
        ms.ServerName,
        ms.DatabaseName,
        ms.SnapshotMonth,
        ms.TotalGB,
        ms.DataGB,
        ms.LogGB,
        rn = ROW_NUMBER() OVER
             (PARTITION BY ms.ServerName, ms.DatabaseName
              ORDER BY ms.SnapshotMonth DESC)
    FROM dbo.Tabela_Crescimento_BDs ms
),
Pareado AS
(
    SELECT
        u.ServerName,
        u.DatabaseName,
        u.SnapshotMonth          AS SnapshotMonth_Ultimo,
        u.TotalGB                AS TotalGB_Ultimo,
        u.DataGB                 AS DataGB_Ultimo,
        u.LogGB                  AS LogGB_Ultimo,
        p.TotalGB                AS TotalGB_Anterior,
        p.SnapshotMonth          AS SnapshotMonth_Anterior
    FROM Ultimo u
    LEFT JOIN dbo.Tabela_Crescimento_BDs p
      ON p.ServerName   = u.ServerName
     AND p.DatabaseName = u.DatabaseName
     AND p.SnapshotMonth =
         (SELECT MAX(x.SnapshotMonth)
          FROM dbo.Tabela_Crescimento_BDs x
          WHERE x.ServerName   = u.ServerName
            AND x.DatabaseName = u.DatabaseName
            AND x.SnapshotMonth < u.SnapshotMonth)
    WHERE u.rn = 1
)
SELECT
    ServerName,
    DatabaseName,
    SnapshotMonth_Ultimo,
    AnoMes_Ultimo = CONVERT(char(7), SnapshotMonth_Ultimo, 126),
    TotalGB_Ultimo,
    DataGB_Ultimo,
    LogGB_Ultimo,
    TotalGB_Anterior,
    SnapshotMonth_Anterior,
    GrowthGB_Calc  = CASE WHEN TotalGB_Anterior IS NULL THEN NULL
                          ELSE CAST(TotalGB_Ultimo - TotalGB_Anterior AS DECIMAL(19,2)) END,
    GrowthPct_Calc = CASE WHEN TotalGB_Anterior IS NULL OR TotalGB_Anterior = 0 THEN NULL
                          ELSE CAST((TotalGB_Ultimo - TotalGB_Anterior) / TotalGB_Anterior * 100.0
                                    AS DECIMAL(9,2)) END
FROM Pareado;
GO


-- select * from vw_Tabela_Crescimento_BDs_UltimoMes
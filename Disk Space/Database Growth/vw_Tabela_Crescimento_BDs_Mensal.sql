USE [dba_db]
GO

/****** Object:  View [dbo].[vw_Tabela_Crescimento_BDs_Mensal]    Script Date: 30/10/2025 18:05:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   VIEW [dbo].[vw_Tabela_Crescimento_BDs_Mensal]
AS
WITH B AS
(
    SELECT
        ms.ServerName,
        ms.DatabaseName,
        ms.SnapshotMonth,                 -- sempre YYYY-MM-01
        ms.TotalGB,
        ms.DataGB,
        ms.LogGB,
        PrevTotalGB = LAG(ms.TotalGB) OVER
                      (PARTITION BY ms.ServerName, ms.DatabaseName
                       ORDER BY ms.SnapshotMonth)
    FROM dbo.Tabela_Crescimento_BDs ms
)
SELECT
    B.ServerName,
    B.DatabaseName,
    B.SnapshotMonth,
    Ano        = YEAR(B.SnapshotMonth),
    Mes        = MONTH(B.SnapshotMonth),
    AnoMes     = CONVERT(CHAR(7), B.SnapshotMonth, 126), -- 'YYYY-MM' (rápido p/ PBI)
    B.TotalGB,
    B.DataGB,
    B.LogGB,
    GrowthGB_Calc  = CASE WHEN B.PrevTotalGB IS NULL THEN 0
                          ELSE CAST(B.TotalGB - B.PrevTotalGB AS DECIMAL(19,2))
                     END,
    GrowthPct_Calc = CASE WHEN B.PrevTotalGB IS NULL OR B.PrevTotalGB = 0 THEN 0
                          ELSE CAST((B.TotalGB - B.PrevTotalGB) / B.PrevTotalGB * 100.0 AS DECIMAL(9,2))
                     END
FROM B;

GO





select * from vw_Tabela_Crescimento_BDs_Mensal
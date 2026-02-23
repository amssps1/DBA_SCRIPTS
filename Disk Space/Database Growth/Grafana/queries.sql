SELECT [ServerName]
      ,[DatabaseName]
      ,[SnapshotMonth]
      ,[TotalGB]
      ,[DataGB]
      ,[LogGB]
      ,[GrowthGB]
      ,[GrowthPct]
      ,[CaptureUTC]
  FROM [dba_db].[dbo].[Tabela_Crescimento_BDs]



    Update [dba_db].[dbo].[Tabela_Crescimento_BDs] set [GrowthGB] = 0 , [GrowthPct] = 0 where
  [SnapshotMonth] = '2025-08-01'



  Update [dba_db].[dbo].[Tabela_Crescimento_BDs] set [SnapshotMonth] = '2025-08-01'
  where [SnapshotMonth] = '2025-09-01'

  
  Update [dba_db].[dbo].[Tabela_Crescimento_BDs] set [GrowthGB] = 0 , [GrowthPct] = 0 , captureUTC = '2025-08-31' where
  [SnapshotMonth] = '2025-08-01'



  SELECT  
    v.ServerName,
    v.DatabaseName,
    v.Ano,
    v.Mes,
    v.AnoMes,
    v.TotalGB,
    v.TotalGB - LAG(v.TotalGB) OVER (
        PARTITION BY v.ServerName, v.DatabaseName 
        ORDER BY v.Ano, v.Mes
    ) AS GrowthGB_Calc
FROM dba_db.dbo.vw_Tabela_Crescimento_BDs_Mensal v
ORDER BY v.ServerName, v.DatabaseName, v.Ano, v.Mes;


-----------------------------------------

SELECT  
    t.ServerName,
    t.DatabaseName,
    CAST(t.SnapshotMonth AS DATE) AS SnapshotMonth,
    SUM(t.TotalGB)      AS TotalGB,
    SUM(t.DataGB)       AS DataGB,
    SUM(t.LogGB)        AS LogGB,
    SUM(t.GrowthGB)     AS GrowthGB,
    AVG(t.GrowthPct)    AS GrowthPct
FROM dba_db.dbo.Tabela_Crescimento_BDs t
GROUP BY 
    t.ServerName,
    t.DatabaseName,
    CAST(t.SnapshotMonth AS DATE)
ORDER BY 
    t.ServerName,
    t.DatabaseName,
    SnapshotMonth;
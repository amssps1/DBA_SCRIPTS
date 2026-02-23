  SELECT
    ServerName, DatabaseName, MONTH(SnapshotMonth) AS Mês,
    TotalGB
FROM dba_db.dbo.Tabela_Crescimento_BDs
WHERE SnapshotMonth >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
  AND SnapshotMonth <  DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
  AND TotalGB > 10.0
ORDER BY ServerName, DatabaseName;
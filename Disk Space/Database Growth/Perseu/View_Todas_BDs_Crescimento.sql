CREATE OR ALTER VIEW [dbo].[vw_Tabela_Crescimento_BDs_Mensal_ALL]

AS
/* Base mensal no último dia de cada mês */
WITH Base AS
(
    SELECT
        ms.ServerName,
        ms.DatabaseName,
        SnapshotMonth = EOMONTH(ms.SnapshotMonth),
        ms.TotalGB
    FROM dbo.Tabela_Crescimento_BDs ms
),
/* Últimos 12 meses (ajusta conforme o teu calendário de reporting) */
Ultimos12 AS
(
    SELECT DISTINCT
        b.ServerName,
        b.DatabaseName,
        b.SnapshotMonth,
        b.TotalGB,
        Mes = FORMAT(b.SnapshotMonth, 'yyyy-MM')
    FROM Base b
    WHERE b.SnapshotMonth >= DATEADD(MONTH, -11, EOMONTH(GETDATE()))
),
/* Determina o tamanho mais recente por BD para aplicar o filtro >= 5 GB */
MaisRecente AS
(
    SELECT u.ServerName, u.DatabaseName, u.TotalGB,
           rn = ROW_NUMBER() OVER (PARTITION BY u.ServerName, u.DatabaseName ORDER BY u.SnapshotMonth DESC)
    FROM Ultimos12 u
),
Elegiveis AS
(
    SELECT ServerName, DatabaseName
    FROM MaisRecente
    WHERE rn = 1 AND TotalGB >= 30.0
)
SELECT
    u.ServerName,
    u.DatabaseName,
    [2025-01] = MAX(CASE WHEN u.Mes = '2025-01' THEN u.TotalGB END),
    [2025-02] = MAX(CASE WHEN u.Mes = '2025-02' THEN u.TotalGB END),
    [2025-03] = MAX(CASE WHEN u.Mes = '2025-03' THEN u.TotalGB END),
    [2025-04] = MAX(CASE WHEN u.Mes = '2025-04' THEN u.TotalGB END),
    [2025-05] = MAX(CASE WHEN u.Mes = '2025-05' THEN u.TotalGB END),
    [2025-06] = MAX(CASE WHEN u.Mes = '2025-06' THEN u.TotalGB END),
    [2025-07] = MAX(CASE WHEN u.Mes = '2025-07' THEN u.TotalGB END),
    [2025-08] = MAX(CASE WHEN u.Mes = '2025-08' THEN u.TotalGB END),
    [2025-09] = MAX(CASE WHEN u.Mes = '2025-09' THEN u.TotalGB END),
    [2025-10] = MAX(CASE WHEN u.Mes = '2025-10' THEN u.TotalGB END),
    [2025-11] = MAX(CASE WHEN u.Mes = '2025-11' THEN u.TotalGB END),
    [2025-12] = MAX(CASE WHEN u.Mes = '2025-12' THEN u.TotalGB END)
FROM Ultimos12 u
JOIN Elegiveis e
  ON e.ServerName   = u.ServerName
 AND e.DatabaseName = u.DatabaseName
GROUP BY
    u.ServerName,
    u.DatabaseName;
GO

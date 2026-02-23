/* ============================================================
   Relatório: Crescimento mensal médio dos backups
   Inclui apenas bases de dados > 10 GB
   Autor : António M. S. Silva
   Data  : 2025-11-07
============================================================ */

WITH DbList AS (
    SELECT 
        d.name AS DatabaseName,
        SizeGB = CAST(SUM(mf.size) * 8.0 / 1024 / 1024 AS DECIMAL(10,2))
    FROM sys.databases d
    JOIN sys.master_files mf ON d.database_id = mf.database_id
    WHERE d.state = 0 -- ONLINE
    GROUP BY d.name
    HAVING SUM(mf.size) * 8.0 / 1024 / 1024 > 10  -- > 10 GB
),
BackupsSize AS (
    SELECT
          [DatabaseName] = b.database_name,
          [Year]  = DATEPART(YEAR, b.backup_start_date),
          [Month] = DATEPART(MONTH, b.backup_start_date),
          [Backup Size GB] = CONVERT(DECIMAL(10,2),
                                     ROUND(AVG(b.backup_size / 1024.0 / 1024 / 1024), 4))
    FROM msdb.dbo.backupset AS b
    INNER JOIN DbList AS dl ON b.database_name = dl.DatabaseName
    WHERE 
          b.[type] = 'D'                         -- full backups
      AND DATEPART(YEAR, b.backup_start_date) = 2025
      AND b.backup_start_date >= '2025-01-01'
      AND b.database_name NOT IN ('SSISDB','AdministracaoSistemas','Hangfire')
    GROUP BY
        b.database_name,
        DATEPART(YEAR, b.backup_start_date),
        DATEPART(MONTH, b.backup_start_date)
)
SELECT 
    [DatabaseName],
    MAX(CASE WHEN [Month] = 1  THEN [Backup Size GB] END) AS [Jan_2025],
    MAX(CASE WHEN [Month] = 2  THEN [Backup Size GB] END) AS [Fev_2025],
    MAX(CASE WHEN [Month] = 3  THEN [Backup Size GB] END) AS [Mar_2025],
    MAX(CASE WHEN [Month] = 4  THEN [Backup Size GB] END) AS [Abr_2025],
    MAX(CASE WHEN [Month] = 5  THEN [Backup Size GB] END) AS [Mai_2025],
    MAX(CASE WHEN [Month] = 6  THEN [Backup Size GB] END) AS [Jun_2025],
    MAX(CASE WHEN [Month] = 7  THEN [Backup Size GB] END) AS [Jul_2025],
    MAX(CASE WHEN [Month] = 8  THEN [Backup Size GB] END) AS [Ago_2025],
    MAX(CASE WHEN [Month] = 9  THEN [Backup Size GB] END) AS [Set_2025],
    MAX(CASE WHEN [Month] = 10 THEN [Backup Size GB] END) AS [Out_2025],
    MAX(CASE WHEN [Month] = 11 THEN [Backup Size GB] END) AS [Nov_2025],
    MAX(CASE WHEN [Month] = 12 THEN [Backup Size GB] END) AS [Dez_2025]
FROM BackupsSize
GROUP BY [DatabaseName]
ORDER BY [DatabaseName];

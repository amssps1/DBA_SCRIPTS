WITH BackupsSize AS (
    SELECT
          rn = ROW_NUMBER() OVER (
                   PARTITION BY [database_name]
                   ORDER BY DATEPART(year,[backup_start_date]) ASC,
                            DATEPART(month,[backup_start_date]) ASC
              )
        , rn_desc = ROW_NUMBER() OVER (
                   PARTITION BY [database_name]
                   ORDER BY DATEPART(year,[backup_start_date]) DESC,
                            DATEPART(month,[backup_start_date]) DESC
              )
        , [DatabaseName] = [database_name]
        , [Year]  = DATEPART(year,[backup_start_date])
        , [Month] = DATEPART(month,[backup_start_date])
        , [Backup Size GB] = CONVERT(DECIMAL(10,2),
                                     ROUND(AVG([backup_size]/1024.0/1024/1024),4))
    FROM msdb.dbo.backupset
    WHERE DATEPART(year,[backup_start_date]) = 2025
      AND [type] = 'D'
      AND backup_start_date BETWEEN DATEADD(month, -13, GETDATE()) AND GETDATE()
      AND [database_name] <> 'TcontrolDAH_Ops'
    GROUP BY
        [database_name],
        DATEPART(year,[backup_start_date]),
        DATEPART(month,[backup_start_date])
    HAVING CONVERT(DECIMAL(10,2),
                   ROUND(AVG([backup_size]/1024.0/1024/1024),4)) > 100
)
SELECT
      f.DatabaseName AS [Database]
    , CONCAT(f.Year,'-', RIGHT('00' + CAST(f.Month AS varchar(2)),2)) AS [Mês 1]
    , f.[Backup Size GB]  AS [Tamanho Mês 1 (GB)]
    , CONCAT(l.Year,'-', RIGHT('00' + CAST(l.Month AS varchar(2)),2)) AS [Último mês]
    , l.[Backup Size GB]  AS [Tamanho Atual (GB)]
    , l.[Backup Size GB] - f.[Backup Size GB] AS [Diferença (GB)]
FROM BackupsSize f
JOIN BackupsSize l
  ON l.DatabaseName = f.DatabaseName
 AND l.rn_desc = 1          -- último mês
WHERE f.rn = 1               -- primeiro mês
ORDER BY f.DatabaseName;

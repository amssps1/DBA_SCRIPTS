--SECTION 1 BEGIN
WITH BackupsSize AS(
    SELECT TOP 1000
          rn = ROW_NUMBER() OVER (
                   PARTITION BY [database_name] 
                   ORDER BY DATEPART(year,[backup_start_date]) ASC, DATEPART(month,[backup_start_date]) ASC
              )
        , [DatabaseName] = [database_name]
        , [Year]  = DATEPART(year,[backup_start_date])
        , [Month] = DATEPART(month,[backup_start_date])
        , [Backup Size GB] = CONVERT(DECIMAL(10,2),ROUND(AVG([backup_size]/1024/1024/1024),4))
    FROM 
        msdb.dbo.backupset
    WHERE 
        DATEPART(year,[backup_start_date]) = 2025
      AND [type] = 'D'
      AND backup_start_date BETWEEN DATEADD(mm, - 13, GETDATE()) AND GETDATE()
      AND [database_name] <> 'TcontrolDAH_Ops'   -- 👈 exclusão da BD
    GROUP BY 
        [database_name]
        , DATEPART(yyyy,[backup_start_date])
        , DATEPART(mm, [backup_start_date])
    HAVING CONVERT(DECIMAL(10,2),ROUND(AVG([backup_size]/1024/1024/1024),4)) > 10
)
--SECTION 1 END
 
--SECTION 2 BEGIN
SELECT 
     b.DatabaseName
   , b.Year
   , b.Month
   , b.[Backup Size GB]
   , 0 AS deltaNormal
FROM BackupsSize b
WHERE b.rn = 1

UNION

SELECT 
     b.DatabaseName
   , b.Year
   , b.Month
   , b.[Backup Size GB]
   , b.[Backup Size GB] - d.[Backup Size GB] AS deltaNormal
FROM BackupsSize b
CROSS APPLY (
   SELECT 
       bs.[Backup Size GB]
   FROM BackupsSize bs
   WHERE bs.rn = b.rn - 1
     AND bs.DatabaseName = b.DatabaseName
) AS d
--SECTION 2 END

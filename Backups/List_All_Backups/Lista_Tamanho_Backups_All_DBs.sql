DROP TABLE IF EXISTS #TEMP;
GO

-- CTE com backups completos das bases de dados de utilizador
;WITH cte_backup AS (
    SELECT 
        CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
        bs.database_name, 
        bs.backup_start_date, 
        bs.backup_finish_date AS Data_Backup, 
        CASE bs.type 
            WHEN 'D' THEN 'Database' 
            WHEN 'I' THEN 'Differential' 
            WHEN 'F' THEN 'Filegroup' 
            WHEN 'P' THEN 'Partial' 
            WHEN 'G' THEN 'Differential File' 
            WHEN 'L' THEN 'Log' 
        END AS backup_type, 
        CAST(bs.backup_size / (1024.0 * 1024 * 1024) AS DECIMAL(10,2)) AS [Total (GB)],
        bmf.logical_device_name, 
        bmf.physical_device_name, 
        bs.name AS backupset_name, 
        bs.description 
    FROM 
        msdb.dbo.backupmediafamily bmf
        INNER JOIN msdb.dbo.backupset bs ON bmf.media_set_id = bs.media_set_id 
    WHERE 
        bs.backup_start_date >= DATEADD(DAY, -1024, GETDATE()) 
        AND bs.type = 'D'
        AND bs.database_name NOT IN ('master','model','tempdb','msdb')
)

-- Inserir numa tabela temporária
SELECT *
INTO #TEMP
FROM cte_backup;

-- Seleciona o backup com maior tamanho por ano e base de dados
;WITH CTE_Rank AS (
    SELECT 
        Server,
        database_name AS DB,
        YEAR(backup_start_date) AS Ano,
        backup_start_date AS Data,
        [Total (GB)],
        ROW_NUMBER() OVER (
            PARTITION BY database_name, YEAR(backup_start_date)
            ORDER BY [Total (GB)] DESC
        ) AS rn
    FROM #TEMP
)

SELECT 
    Server,
    DB,
    Ano,
    FORMAT(Data, 'yyyy-MM') AS Data_Maior_Backup,
    [Total (GB)] AS Maior_Backup_GB
FROM CTE_Rank
WHERE rn = 1
ORDER BY DB, Ano;

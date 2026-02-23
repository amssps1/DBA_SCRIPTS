DECLARE @Desde datetime = DATEADD(DAY, -30, GETDATE());

;WITH Win AS (
    SELECT
        DatabaseName,
        SchemaName,
        TableName,
        CaptureDate,
        UsedKB,
        rn_asc  = ROW_NUMBER() OVER (PARTITION BY DatabaseName, SchemaName, TableName ORDER BY CaptureDate ASC),
        rn_desc = ROW_NUMBER() OVER (PARTITION BY DatabaseName, SchemaName, TableName ORDER BY CaptureDate DESC),
        cnt     = COUNT(*)      OVER (PARTITION BY DatabaseName, SchemaName, TableName)
    FROM dbo.Tabela_Crescimento_Rows
    WHERE CaptureDate >= @Desde
),
Base AS (  -- primeira leitura do período
    SELECT DatabaseName, SchemaName, TableName,
           BaseDate = CaptureDate,
           BaseKB   = UsedKB
    FROM Win
    WHERE rn_asc = 1
),
Atual AS ( -- última leitura do período
    SELECT DatabaseName, SchemaName, TableName,
           AtualDate = CaptureDate,
           AtualKB   = UsedKB
    FROM Win
    WHERE rn_desc = 1
),
Cres AS (
    SELECT
        A.DatabaseName, A.SchemaName, A.TableName,
        B.BaseDate,  AtualDate = A.AtualDate,
        BaseMB  = CONVERT(decimal(19,2), B.BaseKB  / 1024.0),
        AtualMB = CONVERT(decimal(19,2), A.AtualKB / 1024.0),
        CrescMB = CONVERT(decimal(19,2), (A.AtualKB - B.BaseKB) / 1024.0),
        CrescPct = CONVERT(decimal(9,2),
                   CASE WHEN B.BaseKB = 0 THEN NULL
                        ELSE (A.AtualKB - B.BaseKB) * 100.0 / B.BaseKB END)
    FROM Atual A
    JOIN Base  B
      ON B.DatabaseName = A.DatabaseName
     AND B.SchemaName   = A.SchemaName
     AND B.TableName    = A.TableName
)
SELECT TOP (50)
    DatabaseName, SchemaName, TableName,
    BaseDate, AtualDate,
    BaseMB, AtualMB, CrescMB, CrescPct
FROM Cres
-- só mostra quem realmente cresceu (opcional: comenta a próxima linha se quiseres ver quedas/empates)
WHERE CrescMB > 0 AND DatabaseName NOT IN ('OutSystems_Log2023')
ORDER BY CrescMB DESC, AtualMB DESC;
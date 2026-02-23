DECLARE @Desde DATETIME = DATEADD(DAY, -30, GETDATE());

;WITH Win AS (
    SELECT
        DatabaseName,
              TableName,
        CaptureDate,
        UsedKB,
        rn_asc  = ROW_NUMBER() OVER (PARTITION BY DatabaseName, SchemaName, TableName ORDER BY CaptureDate ASC),
        rn_desc = ROW_NUMBER() OVER (PARTITION BY DatabaseName, SchemaName, TableName ORDER BY CaptureDate DESC),
        cnt     = COUNT(*)      OVER (PARTITION BY DatabaseName, SchemaName, TableName)
    FROM dbo.Tabela_Crescimento_Rows
    WHERE CaptureDate >= @Desde
),
Base AS (  -- primeira leitura do período (~há 30 dias)
    SELECT DatabaseName, TableName,
           BaseDate = CaptureDate,
           BaseKB   = UsedKB
    FROM Win
    WHERE rn_asc = 1
),
Atual AS ( -- última leitura do período (mais recente)
    SELECT DatabaseName,  TableName,
           AtualDate = CaptureDate,
           AtualKB   = UsedKB
    FROM Win
    WHERE rn_desc = 1
),
Cres AS (
    SELECT
        A.DatabaseName,  A.TableName,
        B.BaseDate,  
        A.AtualDate,
        BaseMB  = CONVERT(DECIMAL(19,2), B.BaseKB  / 1024.0),
        AtualMB = CONVERT(DECIMAL(19,2), A.AtualKB / 1024.0),
        CrescMB = CONVERT(DECIMAL(19,2), (A.AtualKB - B.BaseKB) / 1024.0),
        CrescPct = CONVERT(DECIMAL(9,2),
                   CASE WHEN B.BaseKB = 0 THEN NULL
                        ELSE (A.AtualKB - B.BaseKB) * 100.0 / B.BaseKB END)
    FROM Atual A
    JOIN Base  B
      ON B.DatabaseName = A.DatabaseName
        AND B.TableName    = A.TableName
)
SELECT TOP (50)
    DatabaseName,
  
    TableName,
    FORMAT(AtualDate, 'dd/MM/yyyy') AS DataMaisRecente,
    CAST(ROUND(BaseMB, 0) AS bigint)  AS Tamanho_Ha30Dias_MB,   -- NOVA COLUNA
    CAST(ROUND(AtualMB, 0) AS bigint) AS Tamanho_Atual_MB,
    CAST(ROUND(CrescMB, 0) AS bigint) AS Crescimento_MB,
    CAST(ROUND(CrescPct, 0) AS int)   AS Crescimento_Pct
FROM Cres
WHERE CrescMB > 50  -- apenas tabelas que cresceram mais de 300 MB
  AND DatabaseName NOT IN ('SSISDB','Outsystems_Log2023')
ORDER BY DatabaseName, Crescimento_MB DESC;

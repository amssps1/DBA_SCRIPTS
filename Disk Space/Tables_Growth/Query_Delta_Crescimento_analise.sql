WITH FirstCapture AS (
    SELECT
        DatabaseName,
        SchemaName,
        TableName,
        MIN(CaptureDate) AS FirstCaptureDate
    FROM dbo.Tabela_Crescimento_Rows
    GROUP BY DatabaseName, SchemaName, TableName
),
InitialCounts AS (
    SELECT 
        f.DatabaseName,
        f.SchemaName,
        f.TableName,
        t.[RowCount] AS InitialRowCount
    FROM FirstCapture f
    INNER JOIN dbo.Tabela_Crescimento_Rows t
        ON f.DatabaseName = t.DatabaseName
        AND f.SchemaName = t.SchemaName
        AND f.TableName = t.TableName
        AND f.FirstCaptureDate = t.CaptureDate
),
LatestCounts AS (
    SELECT 
        DatabaseName,
        SchemaName,
        TableName,
        MAX(CaptureDate) AS LatestDate
    FROM dbo.Tabela_Crescimento_Rows
    GROUP BY DatabaseName, SchemaName, TableName
),
FinalCounts AS (
    SELECT 
        l.DatabaseName,
        l.SchemaName,
        l.TableName,
        t.[RowCount] AS LatestRowCount
    FROM LatestCounts l
    INNER JOIN dbo.Tabela_Crescimento_Rows t
        ON l.DatabaseName = t.DatabaseName
        AND l.SchemaName = t.SchemaName
        AND l.TableName = t.TableName
        AND l.LatestDate = t.CaptureDate
)

SELECT 
    i.DatabaseName,
    i.SchemaName,
    i.TableName,
    i.InitialRowCount,
    f.LatestRowCount,
    f.LatestRowCount - i.InitialRowCount AS TotalDeltaRows
FROM InitialCounts i
INNER JOIN FinalCounts f
    ON i.DatabaseName = f.DatabaseName
    AND i.SchemaName = f.SchemaName
    AND i.TableName = f.TableName
WHERE f.LatestRowCount - i.InitialRowCount <> 0
ORDER BY TotalDeltaRows DESC;

WITH CrescimentoInicialFinal AS (
    SELECT
        t.DatabaseName,
        t.SchemaName,
        t.TableName,
        MIN(t.CaptureDate) AS DataInicio,
        MAX(t.CaptureDate) AS DataFim
    FROM dbo.Tabela_Crescimento_Rows t
    GROUP BY t.DatabaseName, t.SchemaName, t.TableName
),
DadosInicio AS (
    SELECT 
        t.DatabaseName,
        t.SchemaName,
        t.TableName,
        t.CaptureDate AS DataCaptura,
        CAST(t.UsedKB / 1024.0 AS DECIMAL(18,2)) AS MB_Inicial,
        t.[RowCount] AS Rows_Inicial
    FROM dbo.Tabela_Crescimento_Rows t
    INNER JOIN CrescimentoInicialFinal c
        ON t.DatabaseName = c.DatabaseName
        AND t.SchemaName = c.SchemaName
        AND t.TableName = c.TableName
        AND t.CaptureDate = c.DataInicio
),
DadosFim AS (
    SELECT 
        t.DatabaseName,
        t.SchemaName,
        t.TableName,
        t.CaptureDate AS DataCaptura,
        CAST(t.UsedKB / 1024.0 AS DECIMAL(18,2)) AS MB_Final,
        t.[RowCount] AS Rows_Final
    FROM dbo.Tabela_Crescimento_Rows t
    INNER JOIN CrescimentoInicialFinal c
        ON t.DatabaseName = c.DatabaseName
        AND t.SchemaName = c.SchemaName
        AND t.TableName = c.TableName
        AND t.CaptureDate = c.DataFim
),
CrescimentoTotal AS (
    SELECT 
        i.DatabaseName,
        i.SchemaName,
        i.TableName,
        CAST(i.DataCaptura AS DATE) AS DataInicio,
        CAST(f.DataCaptura AS DATE) AS DataFim,
        i.MB_Inicial,
        f.MB_Final,
        CAST(f.MB_Final - i.MB_Inicial AS DECIMAL(18,2)) AS Crescimento_MB
    FROM DadosInicio i
    INNER JOIN DadosFim f
        ON i.DatabaseName = f.DatabaseName
        AND i.SchemaName = f.SchemaName
        AND i.TableName = f.TableName
)
-- Resultado final com filtro Crescimento_Total_MB > 0
SELECT 
    DatabaseName AS BaseDados,
    SUM(MB_Inicial) AS MB_Total_Inicial,
    SUM(MB_Final) AS MB_Total_Final,
    SUM(Crescimento_MB) AS Crescimento_Total_MB
FROM CrescimentoTotal
GROUP BY DatabaseName
HAVING SUM(CAST(Crescimento_MB AS DECIMAL(18,2))) > 0
ORDER BY Crescimento_Total_MB DESC;

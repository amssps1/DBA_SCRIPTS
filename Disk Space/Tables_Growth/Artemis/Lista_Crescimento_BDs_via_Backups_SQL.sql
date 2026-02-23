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
        CAST(f.MB_Final - i.MB_Inicial AS DECIMAL(18,2)) AS Crescimento_MB,
        i.Rows_Inicial,
        f.Rows_Final,
        f.Rows_Final - i.Rows_Inicial AS Crescimento_Rows,
        CASE 
            WHEN i.MB_Inicial = 0 THEN NULL
            ELSE CAST(ROUND(((f.MB_Final - i.MB_Inicial) * 100.0 / i.MB_Inicial), 2) AS DECIMAL(10,2))
        END AS Percentual_Crescimento_MB
    FROM DadosInicio i
    INNER JOIN DadosFim f
        ON i.DatabaseName = f.DatabaseName
        AND i.SchemaName = f.SchemaName
        AND i.TableName = f.TableName
)
SELECT TOP 100
    DatabaseName AS BaseDados,
    SchemaName AS Esquema,
    TableName AS Tabela,
    DataInicio,
    DataFim,
    MB_Inicial,
    MB_Final,
    Crescimento_MB,
    Rows_Inicial,
    Rows_Final,
    Crescimento_Rows,
    Percentual_Crescimento_MB
FROM CrescimentoTotal
ORDER BY Crescimento_MB DESC;

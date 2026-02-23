--- Grafana -- Perseu


WITH Fonte AS (
    SELECT
        t.DatabaseName,
        t.SchemaName,
        t.TableName,
        t.CaptureDate,
        t.UsedKB,
        t.[RowCount]
    FROM dbo.Tabela_Crescimento_Rows t
    WHERE $__timeFilter(t.CaptureDate)
),
CrescimentoInicialFinal AS (
    SELECT
        f.DatabaseName,
        f.SchemaName,
        f.TableName,
        MIN(f.CaptureDate) AS DataInicio,
        MAX(f.CaptureDate) AS DataFim
    FROM Fonte f
    GROUP BY f.DatabaseName, f.SchemaName, f.TableName
),
DadosInicio AS (
    SELECT 
        f.DatabaseName,
        f.SchemaName,
        f.TableName,
        f.CaptureDate AS DataCaptura,
        CAST(f.UsedKB / 1024.0 AS DECIMAL(18,2)) AS MB_Inicial,
        f.[RowCount] AS Rows_Inicial
    FROM Fonte f
    INNER JOIN CrescimentoInicialFinal c
        ON f.DatabaseName = c.DatabaseName
       AND f.SchemaName  = c.SchemaName
       AND f.TableName   = c.TableName
       AND f.CaptureDate = c.DataInicio
),
DadosFim AS (
    SELECT 
        f.DatabaseName,
        f.SchemaName,
        f.TableName,
        f.CaptureDate AS DataCaptura,
        CAST(f.UsedKB / 1024.0 AS DECIMAL(18,2)) AS MB_Final,
        f.[RowCount] AS Rows_Final
    FROM Fonte f
    INNER JOIN CrescimentoInicialFinal c
        ON f.DatabaseName = c.DatabaseName
       AND f.SchemaName  = c.SchemaName
       AND f.TableName   = c.TableName
       AND f.CaptureDate = c.DataFim
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
        YEAR(f.DataCaptura)  AS Ano_Crescimento,
        MONTH(f.DataCaptura) AS Mes_Crescimento
    FROM DadosInicio i
    INNER JOIN DadosFim f
      ON i.DatabaseName = f.DatabaseName
     AND i.SchemaName  = f.SchemaName
     AND i.TableName   = f.TableName
)
SELECT  
    DatabaseName AS BaseDados,
    CONVERT(VARCHAR(10),Ano_Crescimento) + '0' + CONVERT(VARCHAR(2), Mes_Crescimento) AS Mês,
--    SUM(MB_Inicial)      AS MB_Total_Inicial,
--    SUM(MB_Final)        AS MB_Total_Final,
    SUM(Crescimento_MB)  AS Crescimento_Total_MB
FROM CrescimentoTotal
GROUP BY DatabaseName, Ano_Crescimento, Mes_Crescimento
HAVING SUM(CAST(Crescimento_MB AS DECIMAL(18,2))) > 0
ORDER BY Crescimento_Total_MB DESC;

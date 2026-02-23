USE [dba_db]
GO

/****** Object:  View [dbo].[vw_Tabela_Crescimento_Resumo]    Script Date: 30/05/2025 17:40:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER     VIEW [dbo].[vw_Tabela_Crescimento_Resumo]
AS

WITH DadosOrdenados AS (
    SELECT 
        DatabaseName,
        SchemaName,
        TableName,
        CaptureDate,
        UsedKB,
        [RowCount],
        LAG(UsedKB, 1) OVER (PARTITION BY DatabaseName, SchemaName, TableName ORDER BY CaptureDate) AS UsedKB_Anterior,
        LAG([RowCount], 1) OVER (PARTITION BY DatabaseName, SchemaName, TableName ORDER BY CaptureDate) AS RowCount_Anterior
    FROM [dbo].[Tabela_Crescimento_Rows]
)
SELECT 
    DatabaseName AS BaseDados,
    SchemaName AS Esquema,
    TableName AS Tabela,
    CAST(CaptureDate AS DATE) AS DataCaptura,
    UsedKB AS KB_Utilizados,
    [RowCount] AS TotalLinhas,
    -- Diferença diária em KB
    CASE 
        WHEN UsedKB_Anterior IS NULL THEN NULL
        ELSE (UsedKB - UsedKB_Anterior)
    END AS DiferencaKB,
    -- Diferença diária em Rows
    CASE 
        WHEN RowCount_Anterior IS NULL THEN NULL
        ELSE ([RowCount] - RowCount_Anterior)
    END AS DiferencaRows,
    -- Crescimento percentual diário
    CASE 
        WHEN UsedKB_Anterior IS NULL OR UsedKB_Anterior = 0 THEN NULL
        ELSE CAST(((UsedKB - UsedKB_Anterior) * 100.0 / UsedKB_Anterior) AS DECIMAL(10,2))
    END AS PercentualVariacaoKB
FROM DadosOrdenados

GO


SELECT * FROM   [dba_db].[dbo].[vw_Tabela_Crescimento_Resumo]


-- 2 Resumo diário do crescimento total em GB
SELECT 
    'Perseu' AS Instancia,
    DataCaptura AS Dia,
    COUNT(DISTINCT BaseDados) AS TotalBasesDados,
    SUM(DiferencaKB) AS TotalDiferencaKB,
    CAST(SUM(DiferencaKB) / 1024.0 AS DECIMAL(15,2)) AS TotalDiferencaMB,
    CAST(SUM(DiferencaKB) / (1024.0 * 1024.0) AS DECIMAL(15,2)) AS TotalDiferencaGB,
    SUM(DiferencaRows) AS TotalDiferencaRows,
    -- Bases com crescimento positivo
    SUM(CASE WHEN DiferencaKB > 0 THEN 1 ELSE 0 END) AS TabelasComCrescimento,
    -- Bases com redução
    SUM(CASE WHEN DiferencaKB < 0 THEN 1 ELSE 0 END) AS TabelasComReducao,
    -- Bases estáveis
    SUM(CASE WHEN DiferencaKB = 0 OR DiferencaKB IS NULL THEN 1 ELSE 0 END) AS TableasSemAlteracao
FROM [dba_db].[dbo].[vw_Tabela_Crescimento_Resumo]
WHERE DiferencaKB IS NOT NULL  -- Filtra registros com diferença calculada
GROUP BY DataCaptura
ORDER BY DataCaptura DESC;

SELECT * FROM   [dba_db].[dbo].[vw_Tabela_Crescimento_Resumo]


-- 2 Resumo diário do crescimento total em GB
SELECT 
    'CERES' AS Instancia,
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

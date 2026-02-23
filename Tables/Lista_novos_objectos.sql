DECLARE @DataInicio DATE = '2025-03-15';
DECLARE @DataFim DATE = '2025-07-27';

SELECT 
    o.name AS NomeObjeto,
    s.name AS Esquema,
    o.type_desc AS TipoObjeto,
    o.create_date AS DataCriacao,
    o.modify_date AS UltimaAlteracao
FROM sys.objects o
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE 
    o.create_date BETWEEN @DataInicio AND DATEADD(DAY, 1, @DataFim)
    -- se quiser incluir apenas objetos "recentemente criados", mas não apenas modificados:
    -- AND o.create_date = o.modify_date
ORDER BY o.create_date DESC;

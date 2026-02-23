SELECT IdComunicacaoProcessada,  DATALENGTH(XMLData) FROM ComunicacaoProcessada WITH (NOLOCK)

WHERE CreatedDate > '20250420'


SELECT MAX(DATALENGTH(XMLData)) FROM ComunicacaoProcessada WITH (NOLOCK)
WHERE CreatedDate > '20250420'
--GROUP BY IdComunicacaoProcessada



SELECT 
    AVG(CAST(DATALENGTH(XMLData) AS bigint)) AS avg_xml_size_bytes,
    SUM(CAST(DATALENGTH(XMLData) AS bigint)) AS total_xml_size_bytes,
    MIN(CAST(DATALENGTH(XMLData) AS bigint)) AS min_xml_size_bytes,
    MAX(CAST(DATALENGTH(XMLData) AS bigint)) AS max_xml_size_bytes,
    COUNT(*) AS row_count

FROM ComunicacaoProcessada WITH (NOLOCK)
WHERE CreatedDate BETWEEN  '20250301' AND  '20250429'
--GROUP BY IdComunicacaoProcessada



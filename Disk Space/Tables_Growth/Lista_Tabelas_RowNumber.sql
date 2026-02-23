SELECT 
    DatabaseName,
    SchemaName,
    TableName,
    CaptureDate,
    UsedKB,
    ROW_NUMBER() OVER (PARTITION BY DatabaseName, SchemaName, TableName ORDER BY CaptureDate DESC) AS RowNum
FROM dbo.Tabela_Crescimento_Rows
ORDER BY DatabaseName, SchemaName, TableName, CaptureDate DESC;
DECLARE @TableName NVARCHAR(128) = '#tempvw_COM_Contrato_DadosGenericos';
DECLARE @SQL NVARCHAR(MAX);
SET @SQL = '';

SELECT @SQL = @SQL + 
'
SELECT ''' + name + ''' AS DatabaseName, s.name AS SchemaName, t.name AS TableName
FROM [' + name + '].sys.tables t
JOIN [' + name + '].sys.schemas s ON t.schema_id = s.schema_id
WHERE t.name = ''' + @TableName + ''''
FROM sys.databases
WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb');

EXEC sp_executesql @SQL;

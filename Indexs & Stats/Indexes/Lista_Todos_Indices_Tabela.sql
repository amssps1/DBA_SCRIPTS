DECLARE @TableName NVARCHAR(128) = 'cof_baseriscodah'; -- Replace with your table name
DECLARE @SchemaName NVARCHAR(128) = 'dbo'; -- Replace with your schema name

SELECT 
    'CREATE ' + 
    CASE WHEN i.is_unique = 1 THEN 'UNIQUE ' ELSE '' END + 
    i.type_desc + ' INDEX [' + i.name + '] ON [' + @SchemaName + '].[' + @TableName + '] (' + 
    STRING_AGG(COL_NAME(ic.object_id, ic.column_id) + 
               CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END, ', ') 
               COLLATE DATABASE_DEFAULT + ')' +
    ISNULL(' INCLUDE (' + 
           STRING_AGG(COL_NAME(ic.object_id, ic.column_id), ', ') 
           COLLATE DATABASE_DEFAULT + ')', '') +
    ISNULL(' WHERE ' + i.filter_definition COLLATE DATABASE_DEFAULT, '') + ';'
AS CreateIndexScript
FROM sys.indexes i
JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE i.object_id = OBJECT_ID(@SchemaName + '.' + @TableName)
AND i.type_desc NOT IN ('HEAP')
GROUP BY i.name, i.type_desc, i.is_unique, i.filter_definition
ORDER BY i.name;

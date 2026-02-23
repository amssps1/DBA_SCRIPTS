

DECLARE @TableName NVARCHAR(128) = 'OBSOLETA_VG_RulesDistrib'; -- Change to your table name
DECLARE @SchemaName NVARCHAR(128) = 'dbo'; -- Change if using a different schema
DECLARE @sql NVARCHAR(MAX) = '';

-- Drop FOREIGN KEY constraints
SELECT @sql += 'ALTER TABLE [' + @SchemaName + '].[' + @TableName + '] DROP CONSTRAINT [' + name + '];' + CHAR(13)
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID(@SchemaName + '.' + @TableName);

-- Drop CHECK constraints
SELECT @sql += 'ALTER TABLE [' + @SchemaName + '].[' + @TableName + '] DROP CONSTRAINT [' + name + '];' + CHAR(13)
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID(@SchemaName + '.' + @TableName);

-- Drop UNIQUE constraints
SELECT @sql += 'ALTER TABLE [' + @SchemaName + '].[' + @TableName + '] DROP CONSTRAINT [' + name + '];' + CHAR(13)
FROM sys.key_constraints
WHERE parent_object_id = OBJECT_ID(@SchemaName + '.' + @TableName)
AND type = 'UQ';

-- Drop PRIMARY KEY constraints
SELECT @sql += 'ALTER TABLE [' + @SchemaName + '].[' + @TableName + '] DROP CONSTRAINT [' + name + '];' + CHAR(13)
FROM sys.key_constraints
WHERE parent_object_id = OBJECT_ID(@SchemaName + '.' + @TableName)
AND type = 'PK';

-- Drop DEFAULT constraints
SELECT @sql += 'ALTER TABLE [' + @SchemaName + '].[' + @TableName + '] DROP CONSTRAINT [' + name + '];' + CHAR(13)
FROM sys.default_constraints
WHERE parent_object_id = OBJECT_ID(@SchemaName + '.' + @TableName);

-- Execute the generated SQL
PRINT @sql; -- Print SQL for review
EXEC sp_executesql @sql; -- Execute the drop statements

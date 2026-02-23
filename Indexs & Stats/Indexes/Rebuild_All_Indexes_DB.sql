DECLARE @tableSchema varchar(max), 
        @tableName varchar(max),
        @tsql nvarchar(max);

DECLARE cur CURSOR FOR SELECT TABLE_SCHEMA, TABLE_NAME FROM Information_Schema.tables where  table_type ='BASE TABLE'

OPEN cur 

FETCH NEXT FROM cur into @tableSchema, @tableName

WHILE @@FETCH_STATUS = 0 
BEGIN
    SET @tsql ='ALTER INDEX ALL ON [' + @tableSchema + '].[' + @tableName + '] REBUILD;'
    PRINT(@tsql)
    EXEC SP_EXECUTESQL @tsql;
FETCH NEXT FROM cur into @tableSchema, @tableName
END

CLOSE cur
DEALLOCATE cur
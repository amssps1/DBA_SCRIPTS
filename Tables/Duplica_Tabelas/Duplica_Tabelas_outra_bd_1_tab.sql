

DECLARE @SourceDB NVARCHAR(100) = 'dba_db';
DECLARE @TargetDB NVARCHAR(100) = 'Backup_Obsoletos';
DECLARE @TableName NVARCHAR(255);
DECLARE @SQL NVARCHAR(MAX);

-- Create a temporary table to store the list of tables to be copied
DECLARE @TableList TABLE (TableName NVARCHAR(255));

-- Insert the tables to be copied (Change table names accordingly)
INSERT INTO @TableList (TableName)
VALUES 
('Artemis_ObsoleteTables');




-- Loop through each table in the list
DECLARE table_cursor CURSOR FOR
SELECT TableName FROM @TableList;

OPEN table_cursor;
FETCH NEXT FROM table_cursor INTO @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Copying table: ' + @TableName;

    -- Generate SQL to copy table structure and data
    SET @SQL = '
    USE [' + @TargetDB + '];
    IF NOT EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_NAME = ''' + @TableName + '''
    )
    BEGIN
        SELECT * INTO [' + @TargetDB + '].dbo.[' + @TableName + '] 
        FROM [' + @SourceDB + '].dbo.[' + @TableName + '];
    END
    ELSE
    BEGIN
        INSERT INTO [' + @TargetDB + '].dbo.[' + @TableName + ']
        SELECT * FROM [' + @SourceDB + '].dbo.[' + @TableName + '];
    END';

    -- Execute the generated SQL
    EXEC sp_executesql @SQL;

    -- Move to the next table
    FETCH NEXT FROM table_cursor INTO @TableName;
END;

-- Close and deallocate the cursor
CLOSE table_cursor;
DEALLOCATE table_cursor;

PRINT 'Table duplication completed!';





















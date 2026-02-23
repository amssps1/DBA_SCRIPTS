/*requires Schema.SpaceSnap.sql*/
/*requires Table.SpaceSnap.ObjectSpaceHist.sql*/

DECLARE @ProcedureSchema NVARCHAR(256);
DECLARE @ProcedureName   NVARCHAR(256);

SET @ProcedureSchema = 'SpaceSnap' ;
SET @ProcedureName = 'CaptureObjectUsage' ;

RAISERROR('-----------------------------------------------------------------------------------------------------------------',0,1);
RAISERROR('PROCEDURE [%s].[%s]',0,1,@ProcedureSchema,@ProcedureName);

IF  NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[' + @ProcedureSchema + N'].[' + @ProcedureName +  N']') AND type in (N'P'))
BEGIN
    BEGIN TRY
        EXECUTE ('CREATE Procedure [' + @ProcedureSchema + '].[' + @ProcedureName +  '] ( ' +
                ' @ServerName    varchar(512), ' +
                ' @DbName    varchar(50) ' +
                ') ' +
                'AS ' +
                'BEGIN ' +
                '   SELECT ''Not implemented'' ' +
                'END')
    END TRY
    BEGIN CATCH
        PRINT '   Error while trying to create procedure'
        RETURN
    END CATCH

    PRINT '   PROCEDURE created.'
END
GO

ALTER PROCEDURE [SpaceSnap].[CaptureObjectUsage] ( 
    @CollectionMode                 VARCHAR(256),
    @DatabaseName                   VARCHAR(256) = NULL,
    @ObjectType                     VARCHAR(256) = 'TABLE',
    @ObjectSchemaName               VARCHAR(256) = NULL,
    @ObjectName                     VARCHAR(256) = NULL,
    @PartitionName                  VARCHAR(256) = NULL,
    @ColumnName                     VARCHAR(256) = NULL,
    @RowFilter                      VARCHAR(4000) = NULL, -- kind of where clause. Can be used for Columns count and size collection 
                                                          -- if none is defined then, for COLUMN ObjectType collection, it only takes into account NON NULL rows for row count
    @ParameterDatabaseName          VARCHAR(256) = NULL,
    @ParameterSchemaName            VARCHAR(256) = 'SpaceSnap',
    @ParameterTableName             VARCHAR(256) = 'MonitoredObjects',
    @ReturnCollectionResults        BIT          = 0,
    @DestinationDatabaseName        VARCHAR(256) = NULL,
    @DestinationSchemaName          VARCHAR(256) = 'SpaceSnap',
    @DestinationTableName           VARCHAR(256) = 'ObjectSpaceHist',
    @_RecLevel                      INT          = 0,
    @_CollectionTime                DATETIME2    = NULL,
    @Debug                          BIT          = 0
)
AS
/*
  ===================================================================================
    DESCRIPTION:
        Captures space usage for tables based on a its parameters and stores results to a destination 
        table which is by default SpaceSnap.ObjectSpaceHist

    PARAMETERS:
    
        @CollectionMode             Tells the stored procedure in which mode it should work.
                                    available values are:
                                        DATABASE        => all tables in @DatabaseName database,
                                        SCHEMA          => all tables in a given schema for @DatabaseName,
                                                            If a value is provided for @SchemaName, this value is used as filter
                                        OBJECT          => take into account all provided parameters,
                                        PARAMETERIZED   => is for automated collection mode. In that mode, the parameter @ReturnCollectionResults cannot be set to 1
                                        
                                    TODO: Could be some day: FILEGROUP       => all tables stored in a given filegroup of database @DatabaseName. 
                                        
                                    At the moment, only OBJECT and PARAMETERIZED are implemented.

        @DatabaseName               Name of the database in which we should look at.
                                    If empty or NULL value is provided, it's the value of DB_NAME() that is used
        @ObjectType                 type of the object we want to monitor.
                                    Acceptable values are:
                                        TABLE
                                        
                                    Should be available in the future (TODO)
                                        TABLE PARTITION
                                        TABLE COLUMN
                                        INDEX                                    
                                        INDEXED VIEW
                                        TABLE PARTITION 
                                        PARTITION INDEX
                                        ...
                                
        @ObjectSchemaName           name of the schema in which the object to be collected is stored
        @ObjectName                 name of the object to monitor
        @PartitionName              name of the partition of a table or index whose size has to be collected
        @ColumnName                 name of the column of an object that has to be monitored
        
        @ParameterDatabaseName      name of the database in which parameter table can be found  
                                    If empty or NULL value is provided, it's the value of DB_NAME() that is used
        @ParameterSchemaName        name of the schema in which parameter table can be found
        @ParameterTableName         name of the table in which parameters for this procedure can be found when @CollectionMode value is 'PARAMETERIZED'
        
        @DestinationDatabaseName    name of the database where resides the table in which store results
                                    If empty or NULL value is provided, it's the value of DB_NAME() that is used
        @DestinationSchemaName      name of the schema where resides the table in which store results
        @DestinationTableName       name of the table in which store results
                            
                                
    REQUIREMENTS:

    EXAMPLE USAGE :
    
		-- Capture for particular table in current database

        EXEC [SpaceSnap].[CaptureObjectUsage] 
				@CollectionMode		= 'OBJECT',
				@ObjectType			= 'TABLE',
				@ObjectSchemaName	= 'Common',
				@ObjectName			= 'CommandLog',
				@Debug				= 1
		; 
        
		-- Capture for particular table in another database

        EXEC [SpaceSnap].[CaptureObjectUsage] 
				@CollectionMode		= 'OBJECT',
                @DatabaseName       = 'AdventureWorks',
				@ObjectType			= 'TABLE',
				@ObjectSchemaName	= 'Production',
				@ObjectName			= 'Product',
				@Debug				= 1
		;

		-- Capture from parameterized table
		EXEC SpaceSnap.MonitoredObjects_Insert 
					@DatabaseName = 'testJEL',
					@ObjectType = 'TABLE',
					@SchemaName='Common',
					@ObjectName='CommandLog',
					@SnapIntervalUnit='MINUTE',
					@SnapIntrvalValue=2,
					@SnapSpace=1

		EXEC [SpaceSnap].[CaptureObjectUsage] 
				@CollectionMode		= 'PARAMETERIZED',
				@Debug				= 1
		;

		-- Schema based collection
		
		EXEC [SpaceSnap].[CaptureObjectUsage] 
				@CollectionMode		= 'SCHEMA',
				@ObjectSchemaName   = 'Common',
				@Debug				= 1
		;
        
        -- Column size collection
		EXEC [SpaceSnap].[CaptureObjectUsage] 
				@CollectionMode		= 'OBJECT',
				@ObjectType			= 'TABLE COLUMN',
				@ObjectSchemaName	= 'Testing',
				@ObjectName			= 'TableToMonitor',
				@ColumnName         = 'VarcharMaxCol',
				@Debug				= 1
		;


		select * From SpaceSnap.ObjectSpaceHist

		select * From SpaceSnap.MonitoredObjects
  ===================================================================================
*/
BEGIN
    SET NOCOUNT ON;
    DECLARE @tsql                       nvarchar(max);
    DECLARE @LineFeed                   CHAR(2);
    DECLARE @Padding                    VARCHAR(200);
    DECLARE @TmpFloat                   decimal(36, 2);
    DECLARE @TmpCnt                     BIGINT;
	DECLARE @TmpBit                     BIT;
    DECLARE @ExecRet                    INT;
    DECLARE @ProcedureName              VARCHAR(1024);
	DECLARE @CollectionTime				DATETIME2;
    DECLARE @RowsCount                  BIGINT;
	DECLARE @CurrentAssetId               BIGINT;
    
	DECLARE @ErrorOccurred              BIT;
	DECLARE @ErrorMsg                   VARCHAR(MAX);
    DECLARE @CurrentObjectFullName      VARCHAR(2048);

    DECLARE @DestinationTableFullName   VARCHAR(1024);
    DECLARE @ParameterTableFullName     VARCHAR(1024);
    DECLARE @ColumnExistsCheckPassed    BIT;

    SELECT
        @ProcedureName              = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + '.' + QUOTENAME(OBJECT_NAME(@@PROCID)),
        @tsql                       = '',
		@CollectionTime             = CASE WHEN @_CollectionTime IS NULL THEN SYSDATETIME() ELSE @_CollectionTime END,
        @LineFeed                   = CHAR(13) + CHAR(10),
        @CollectionMode             = CASE WHEN LEN(LTRIM(RTRIM(@CollectionMode))) = 0 THEN NULL ELSE UPPER(@CollectionMode) END,
        @DatabaseName               = CASE WHEN @DatabaseName IS NULL OR LEN(LTRIM(RTRIM(@DatabaseName))) = 0 THEN DB_NAME() ELSE @DatabaseName END,
        @ObjectSchemaName           = CASE WHEN LEN(LTRIM(RTRIM(@ObjectSchemaName))) = 0 THEN NULL ELSE @ObjectSchemaName END,
        @ObjectName                 = CASE WHEN LEN(LTRIM(RTRIM(@ObjectName))) = 0 THEN NULL ELSE @ObjectName END,
        @PartitionName              = CASE WHEN LEN(LTRIM(RTRIM(@PartitionName))) = 0 THEN NULL ELSE @PartitionName END,
        @ColumnName                 = CASE WHEN LEN(LTRIM(RTRIM(@ColumnName))) = 0 THEN NULL ELSE @ColumnName END,
        @ParameterDatabaseName      = CASE WHEN @ParameterDatabaseName IS NULL OR LEN(LTRIM(RTRIM(@ParameterDatabaseName))) = 0 THEN DB_NAME() ELSE @ParameterDatabaseName END,
        @DestinationDatabaseName    = CASE WHEN @DestinationDatabaseName IS NULL OR LEN(LTRIM(RTRIM(@DestinationDatabaseName))) = 0 THEN DB_NAME() ELSE @DestinationDatabaseName END,
        @DestinationSchemaName      = CASE WHEN LEN(LTRIM(RTRIM(@DestinationSchemaName))) = 0 THEN NULL ELSE @DestinationSchemaName END,
        @DestinationTableName       = CASE WHEN LEN(LTRIM(RTRIM(@DestinationTableName))) = 0 THEN NULL ELSE @DestinationTableName END,        
        @DestinationTableFullName   = QUOTENAME(@DestinationDatabaseName) + '.' + QUOTENAME(@DestinationSchemaName) + '.' + QUOTENAME(@DestinationTableName),
        @ParameterSchemaName        = CASE WHEN LEN(LTRIM(RTRIM(@ParameterSchemaName))) = 0 THEN NULL ELSE @ParameterSchemaName END,
        @ParameterTableName         = CASE WHEN LEN(LTRIM(RTRIM(@ParameterTableName))) = 0 THEN NULL ELSE @ParameterTableName END,
        @ParameterTableFullName     = QUOTENAME(@ParameterDatabaseName) + '.' + QUOTENAME(@ParameterSchemaName) + '.' + QUOTENAME(@ParameterTableName),
        @RowFilter                  = CASE WHEN LEN(LTRIM(RTRIM(@RowFilter))) = 0 THEN NULL ELSE @RowFilter END,
        @_RecLevel                  = CASE WHEN @_RecLevel < 1 THEN 0 WHEN @_RecLevel > 50 THEN 50 ELSE @_RecLevel END,
        @Padding                    = REPLICATE('    ',@_RecLevel)
    ;

    if (@Debug = 1)
    BEGIN
        RAISERROR('%s-- -----------------------------------------------------------------------------------------------------------------',0,1,@Padding);
        RAISERROR('%s-- Now running %s stored procedure.',0,1,@Padding,@ProcedureName);
        RAISERROR('%s-- -----------------------------------------------------------------------------------------------------------------',0,1,@Padding);
    END;
    

    if (@Debug = 1)
    BEGIN
        RAISERROR('%s-- Checking parameters',0,1,@Padding);
    END;
    
    IF(@CollectionMode NOT IN ('DATABASE','SCHEMA'/*,'FILEGROUP'*/,'OBJECT','PARAMETERIZED'))
    BEGIN
        RAISERROR('Unknown collection mode [%s]',12,1,@CollectionMode);
        RETURN;
    END;
    
    IF(@CollectionMode = 'PARAMETERIZED' AND @ReturnCollectionResults = 1)
    BEGIN
        RAISERROR('%sWarning: setting @ReturnCollectionResults to 0 as PARAMETERIZED mode used',0,1,@Padding);
        SET @ReturnCollectionResults = 0;
    END;
    
    IF(@CollectionMode <> 'OBJECT')
    BEGIN
        IF(@Debug = 1)
        BEGIN
            RAISERROR('%s-- Ignoring optional row filter parameter',0,1,@Padding);
        END;
        
        SET @RowFilter = NULL;
    END;    
    
    IF(@CollectionMode IN ('DATABASE','SCHEMA'))
    BEGIN
        IF(@Debug = 1)
        BEGIN
            RAISERROR('%s-- Object type forced to TABLE as Collection mode is [%s]',0,1,@Padding,@CollectionMode);
        END;
        SET @ObjectType = 'TABLE';
    END;

    IF(@ObjectType NOT IN ('TABLE','TABLE PARTITION','TABLE COLUMN'))
    BEGIN
        RAISERROR('Unknown object type [%s]',12,1,@ObjectType);
        RETURN;
    END;
        
    -- TODO: remove it 
    IF(@ObjectType NOT IN ('TABLE','TABLE COLUMN'))
    BEGIN
        RAISERROR('%sHandler for object type [%s] is not implemented yet',12,1,@Padding,@ObjectType);
        RETURN;
    END;
    
    IF(@DestinationSchemaName IS NULL OR @DestinationTableName IS NULL)
    BEGIN
        RAISERROR('Please, provide all parameters to define destination table name',12,1);
        RETURN;
    END;
    
    IF(@CollectionMode = 'PARAMETERIZED' AND (@ParameterSchemaName IS NULL OR @ParameterTableName IS NULL))
    BEGIN
        RAISERROR('Mandatory settings for parameter table schema and table names',12,1);
        RETURN;
    END;
    
    -- destination parameters and destination table creation if it does not exist
    
    IF(@ReturnCollectionResults = 0)
    BEGIN 
        IF(DB_ID(@DestinationDatabaseName) IS NULL)
        BEGIN
            RAISERROR('No database found with name [%s]',12,1,@DestinationDatabaseName);
            RETURN;
        END;
        
        SET @tsql = 'USE ' + QUOTENAME(@DestinationDatabaseName) + ';' + @LineFeed + 
                    'SELECT @cnt = CASE WHEN OBJECT_ID(''' + QUOTENAME(@DestinationSchemaName) + '.' + QUOTENAME(@DestinationTableName) + ''') IS NULL THEN 0 ELSE 1 END;'
                    ;
                    
        exec sp_executesql @tsql , N'@cnt TINYINT OUTPUT', @cnt = @TmpCnt OUTPUT;
    
        IF(@TmpCnt = 0)
        BEGIN
            IF(@Debug = 1)
            BEGIN
                RAISERROR('%s-- Creating destination table',0,1,@Padding);
            END;
            /* Equivalent to : create table as SELECT * FROM SpaceSnap.ObjectSpaceHist WHERE 1 = 2; */
            SET @tsql = 'USE ' + QUOTENAME(@DestinationDatabaseName) + ';' + @LineFeed + 
                        'CREATE TABLE ' + QUOTENAME(@DestinationSchemaName) + '.' + QUOTENAME(@DestinationTableName) + ' (' + @LineFeed + 
                        '    SnapDate        DATETIME2       NOT NULL,' + @LineFeed + 
                        '    ServerName      VARCHAR(512)    NOT NULL,' + @LineFeed + 
                        '    ObjectType      VARCHAR(32)     NOT NULL,' + @LineFeed + 
                        '    DatabaseName    VARCHAR(256)    NOT NULL,' + @LineFeed + 
                        '    SchemaName      VARCHAR(256)    NOT NULL,' + @LineFeed + 
                        '    ObjectName      VARCHAR(256)    NOT NULL,' + @LineFeed + 
                        '    PartitionName   VARCHAR(256)    NULL,' + @LineFeed + 
                        '    ColumnName      VARCHAR(256)    NULL,' + @LineFeed + 
                        '    RowFilter       VARCHAR(4000)   NULL,' + @LineFeed + 
                        '    RowsCount       BIGINT          NULL,' + @LineFeed + 
                        '    TotalSizeMb     decimal(36, 2)  NOT NULL,' + @LineFeed + 
                        '    UsedSizeMb      decimal(36, 2)  NOT NULL,' + @LineFeed + 
                        '    ObjectUniqueId  AS  CAST(' + @LineFeed +
                        '            HASHBYTES(' + @LineFeed +
                        '                ''SHA1'',' + @LineFeed +
                        '                ServerName + DatabaseName + ObjectType + SchemaName + ObjectName + ISNULL(PartitionName,'''') + ISNULL(ColumnName,'''')' + @LineFeed +
                        '            )' + @LineFeed +
                        '            AS VARBINARY(20)' + @LineFeed +
                        '        ) PERSISTED  NOT NULL' + @LineFeed +
                        ')' + @LineFeed 
                        ;
            exec @ExecRet = sp_executesql @tsql;
            
            IF(@ExecRet <> 0)
            BEGIN
                RAISERROR('An error occurred while trying to create destination table',12,1);
                RETURN;
            END;
        END;
        ELSE
        BEGIN
            -- TODO: check table has (at least) the right columns with the right data type and size 
            IF(@Debug = 1)
            BEGIN
                RAISERROR('%s-- Destination table already exists',0,1,@Padding);
            END;
        END;
    END;
    
    if (@Debug = 1)
    BEGIN
        RAISERROR('%s-- Performing collection',0,1,@Padding);
    END;
    
    IF(@CollectionMode <> 'PARAMETERIZED' AND @ObjectType = 'TABLE')
    BEGIN
		IF(@Debug = 1)
		BEGIN
			RAISERROR('%s--     > Table Mode',0,1,@Padding);
		END;	

        SET @tsql = 'USE ' + QUOTENAME(@DatabaseName) + ';' + @LineFeed +
                    'With ObjectsOfInterest (' + @LineFeed +
                    '    ObjectId,SchemaId,ObjectType,DatabaseName,SchemaName,ObjectName,PartitionName,ColumnName' + @LineFeed +
                    ')' + @LineFeed + 
                    'AS (';

        SET @tsql = @tsql + @LineFeed + 
                    '    SELECT ' + @LineFeed + 
                    '        object_id,' + @LineFeed + 
                    '        schema_id,' + @LineFeed + 
                    '        ''TABLE'',' + @LineFeed + 
                    '        DB_NAME(),' + @LineFeed + 
                    '        SCHEMA_NAME(schema_id),' + @LineFeed + 
                    '        OBJECT_NAME(object_id),' + @LineFeed + 
                    '        '''' as PartitionName,' + @LineFeed + 
                    '        '''' as ColumnName' + @LineFeed + 
                    '    FROM ' + @LineFeed + 
                    '        sys.tables t' + @LineFeed + 
                    CASE
                        WHEN @CollectionMode = 'OBJECT' 
                            THEN
                                '    WHERE object_id = object_id(''' + QUOTENAME(@ObjectSchemaName) + '.' + QUOTENAME(@ObjectName) + ''')' + @LineFeed 
                        WHEN @CollectionMode = 'SCHEMA' 
                            THEN '    WHERE schema_id = SCHEMA_ID(''' + @ObjectSchemaName + ''')'
                        ELSE ''
                    END +      
                    ')' + @LineFeed +
                    CASE 
                        WHEN @ReturnCollectionResults = 0 THEN 
                            'INSERT INTO ' + @DestinationTableFullName + '(' + @LineFeed +
                            '    SnapDate,ServerName,ObjectType,DatabaseName,SchemaName,ObjectName,PartitionName,ColumnName,RowsCount,TotalSizeMB,UsedSizeMB' + @LineFeed +
                            ')' + @LineFeed
                        ELSE ''
                    END +
                    'SELECT' + @LineFeed +
                    '    @SnapDate     as SnapDate,' + @LineFeed +
                    '    @@SERVERNAME  as ServerName,' + @LineFeed +
                    '    oi.ObjectType as ObjectType,' + @LineFeed +
                    '    oi.DatabaseName,' + @LineFeed +
                    '    oi.SchemaName,' + @LineFeed +
                    '    oi.ObjectName,' + @LineFeed +
                    '    CASE WHEN oi.PartitionName = '''' THEN NULL ELSE oi.PartitionName END as PartitionName,' + @LineFeed +
                    '    CASE WHEN oi.ColumnName = '''' THEN NULL ELSE oi.ColumnName END as ColumnName,' + @LineFeed +
                    '    p.rows AS RowsCount,' + @LineFeed +
                    '    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,' + @LineFeed +
                    '    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB' + @LineFeed +
                    'FROM ObjectsOfInterest oi' + @LineFeed +
                    'INNER JOIN      ' + @LineFeed +
                    '    sys.indexes i ON oi.ObjectId = i.object_id' + @LineFeed +
                    'INNER JOIN ' + @LineFeed +
                    '    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id' + @LineFeed +
                    'INNER JOIN ' + @LineFeed +
                    '    sys.allocation_units a ON p.partition_id = a.container_id' + @LineFeed +
                    'group by ' + @LineFeed +
                    '    oi.ObjectType,' + @LineFeed +
                    '    oi.DatabaseName,' + @LineFeed +
                    '    oi.SchemaName,' + @LineFeed +
                    '    oi.ObjectName,' + @LineFeed +
                    '    oi.PartitionName,' + @LineFeed +
                    '    oi.ColumnName,' + @LineFeed +
                    '    p.rows' + @LineFeed +
                    ';'
                    ;
        IF(@Debug = 1)
        BEGIN
            RAISERROR(@tsql,0,1,@Padding);
        END;
        
		exec @ExecRet = sp_executesql @tsql , N'@SnapDate DATETIME2', @SnapDate = @CollectionTime;

		IF(@ExecRet <> 0)
		BEGIN
		    RAISERROR('An error occurred during collection',12,1);
		END;
    END;
    
    IF(@CollectionMode <> 'PARAMETERIZED' AND @ObjectType = 'TABLE COLUMN')
    BEGIN
		IF(@Debug = 1)
		BEGIN
			RAISERROR('%s--     > Column Mode',0,1,@Padding);
		END;	

        IF(@DatabaseName IS NULL OR @ObjectSchemaName IS NULL OR @ObjectName IS NULL OR @ColumnName IS NULL)
        BEGIN
            RAISERROR('One or more parameters from following list are missing: database, schema, object or column',12,1);
            RETURN;
        END;
        
		-- check table exists
        SET @tsql = 'USE ' + QUOTENAME(@DatabaseName) + ';' + @LineFeed +
                    'SELECT @oe = CASE WHEN OBJECT_ID(''' + QUOTENAME(@ObjectSchemaName) + '.' + QUOTENAME(@ObjectName) + ''') IS NULL THEN 0 ELSE 1 END;'
                    ;

        IF(@Debug = 1)
        BEGIN
            RAISERROR('%sNext query to run: %s',0,1,@Padding,@tsql);
        END;
                    
        EXEC sp_executesql @tsql, N'@oe BIT OUTPUT', @oe = @TmpBit OUTPUT ;
        
        IF(@TmpBit <> 1)
        BEGIN
            RAISERROR('Table [%s].[%s] does not exist in database [%s]',12,1,@ObjectSchemaName,@ObjectName,@DatabaseName);
            RETURN;
        END;
        
		-- check column exists
        SET @tsql = 'USE ' + QUOTENAME(@DatabaseName) + ';' + @LineFeed +
                    'select @cnt = count(*) ' + @LineFeed +
                    'FROM sys.all_columns' + @LineFeed +
                    'WHERE object_id = OBJECT_ID(''' + QUOTENAME(@ObjectSchemaName) + '.' + QUOTENAME(@ObjectName) + ''')' + @LineFeed +
                    '  AND name = ''' + @ColumnName + '''' + @LineFeed +
                    ';'
                    ;
        
        IF(@Debug = 1)
        BEGIN
            RAISERROR('%sNext query to run: %s',0,1,@Padding,@tsql);
        END;
                    
        EXEC sp_executesql @tsql, N'@cnt INT OUTPUT', @cnt = @TmpCnt OUTPUT ;
        
        IF(@TmpCnt <> 1)
        BEGIN
            RAISERROR('No column found with name [%s] in table [%s].[%s] does not exist in database [%s]',12,1,@ColumnName,@ObjectSchemaName,@ObjectName,@DatabaseName);
            RETURN;
        END;
        
        /*
            Here, we are sure that everything exists.
        */
        
        SET @tsql = 'USE ' + QUOTENAME(@DatabaseName) + ';' + @LineFeed +
                    'SELECT @sumlength = SUM(DATALENGTH(' + QUOTENAME(@ColumnName) + ')) / 1024 / 1024' + @LineFeed +
                    'FROM ' + QUOTENAME(@ObjectSchemaName) + '.' + QUOTENAME(@ObjectName) + @LineFeed +
                    CASE WHEN @RowFilter IS NULL THEN '' ELSE 'WHERE ' + @RowFilter END +
                    ';'
                    ;

        IF(@Debug = 1)
        BEGIN
            RAISERROR('%sNext query to run: %s',0,1,@Padding,@tsql);
        END;
                    
        EXEC sp_executesql @tsql, N'@sumlength decimal(36, 2) OUTPUT', @sumlength = @TmpFloat OUTPUT ;
        
        SET @tsql = 'USE ' + QUOTENAME(@DatabaseName) + ';' + @LineFeed +
                    'SELECT @cnt = COUNT_BIG(*)' + @LineFeed +
                    'FROM ' + QUOTENAME(@ObjectSchemaName) + '.' + QUOTENAME(@ObjectName) + @LineFeed +
                    'WHERE ' + QUOTENAME(@ColumnName) + ' IS NOT NULL' + @LineFeed +
                    CASE WHEN @RowFilter IS NULL THEN '' ELSE 'AND ' + @RowFilter END +
                    ';'
                    ;

        EXEC sp_executesql @tsql, N'@cnt BIGINT OUTPUT', @cnt = @RowsCount OUTPUT ;
        
        SET @tsql = CASE 
                        WHEN @ReturnCollectionResults = 0 THEN 
                            'INSERT INTO ' + @DestinationTableFullName + '(' + @LineFeed +
                            '    SnapDate,ServerName,ObjectType,DatabaseName,SchemaName,ObjectName,PartitionName,ColumnName,RowsCount,TotalSizeMB,UsedSizeMB' + @LineFeed +
                            ')' + @LineFeed
                        ELSE ''
                    END +
                    'SELECT' + @LineFeed +
                    '    @SnapDate     as SnapDate,' + @LineFeed +
                    '    @@SERVERNAME  as ServerName,' + @LineFeed +
                    '    @ObjectType as ObjectType,' + @LineFeed +
                    '    @DatabaseName as DatabaseName,' + @LineFeed +
                    '    @SchemaName    as SchemaName,' + @LineFeed +
                    '    @ObjectName as ObjectName,' + @LineFeed +
                    '    @PartitionName as PartitionName,' + @LineFeed +
                    '    @ColumnName as ColumnName,' + @LineFeed +
                    '    @RowsCount as RowsCount,' + @LineFeed +
                    '    @sumlength AS TotalSpaceMB,' + @LineFeed +
                    '    @sumlength AS UsedSpaceMB' + @LineFeed
                    ;
                    
        IF(@Debug = 1)
        BEGIN
            RAISERROR(@tsql,0,1,@Padding);
        END;
        
		exec @ExecRet = sp_executesql 
                            @tsql , 
                            N'@SnapDate DATETIME2,@ObjectType VARCHAR(256),@DatabaseName VARCHAR(256),@SchemaName VARCHAR(256),@ObjectName VARCHAR(256), @PartitionName VARCHAR(256),@ColumnName VARCHAR(256),@RowsCount BIGINT,@sumlength decimal(36, 2)', 
                            @SnapDate       = @CollectionTime,
                            @ObjectType     = @ObjectType,
                            @DatabaseName   = @DatabaseName,
                            @SchemaName     = @ObjectSchemaName,
                            @ObjectName     = @ObjectName,
                            @PartitionName  = @PartitionName,
                            @ColumnName     = @ColumnName,
                            @RowsCount      = @RowsCount,
                            @sumlength      = @TmpCnt
                            
        ;

		IF(@ExecRet <> 0)
		BEGIN
		    RAISERROR('An error occurred during collection',12,1);
		END;
    END;
    
    IF(@CollectionMode = 'PARAMETERIZED')
    BEGIN
    
        IF(@Debug = 1)
        BEGIN
            RAISERROR('%s-- Running using parameter table %s',0,1,@Padding,@ParameterTableFullName);
        END;
    
    
        IF(OBJECT_ID('tempdb..#Cmds2Run') IS NOT NULL)
        BEGIN
            EXEC sp_executesql N'DROP #Cmds2Run' ;
        END;
        
        CREATE TABLE #Cmds2Run (
            CmdId       INT IDENTITY(1,1),
            FullName    VARCHAR(2048),
            Tsql        NVARCHAR(MAX),
            Outcome     VARCHAR(16),
            LogMsg      VARCHAR(4000)
        );  
        
        SET @tsql = 'DECLARE @LineFeed CHAR(2);' + @LineFeed +
                    'SET @LineFeed = CHAR(13) + CHAR(10);' + @LineFeed +
                    'INSERT INTO #Cmds2Run ('  + @LineFeed +
                    '    FullName,Tsql' + @LineFeed +
                    ')' + @LineFeed +
                    'SELECT' + @LineFeed +
                    '    ObjectType + '': '' + ' + @LineFeed + 
                    '        QUOTENAME(DatabaseName) + ''.'' + QUOTENAME(SchemaName) + ''.'' + QUOTENAME(ObjectName) +' + @LineFeed +
                    '            CASE WHEN PartitionName IS NULL THEN '''' ELSE '' | PARTITION='' + PartitionName END + ' + @LineFeed + 
                    '            CASE WHEN ColumnName    IS NULL THEN '''' ELSE '' | COLUMN='' + ColumnName END ,' + @LineFeed +
                    '    ''USE ' + QUOTENAME(DB_NAME()) + ';'' + @LineFeed +' + @LineFeed +
                    '    ''EXEC ' + @ProcedureName + ''' + @LineFeed +' + @LineFeed +
                    '    ''            @CollectionMode        = ''''OBJECT'''','' + @LineFeed +' + @LineFeed + 
                    '    ''            @DatabaseName          = '''''' + DatabaseName + '''''','' + @LineFeed +' + @LineFeed +
                    '    ''            @ObjectType            = '''''' + ObjectType + '''''','' + @LineFeed +' + @LineFeed +
                    '    ''            @ObjectSchemaName      = '''''' + SchemaName + '''''','' + @LineFeed +' + @LineFeed +
                    '    ''            @ObjectName            = '''''' + ObjectName + '''''','' + @LineFeed +' + @LineFeed +
                    '    ''            @PartitionName         = '' + CASE WHEN PartitionName IS NULL THEN ''NULL'' ELSE '''' + PartitionName + '''' END + '','' + @LineFeed +' + @LineFeed +
                    '    ''            @ColumnName            = '' + CASE WHEN ColumnName    IS NULL THEN ''NULL'' ELSE '''' + ColumnName + '''' END + '','' + @LineFeed +' + @LineFeed +
                    '    ''            @RowFilter             = '' + CASE WHEN SnapRowFilter    IS NULL THEN ''NULL'' ELSE '''' + REPLACE(SnapRowFilter,'''','''''''') + '''' END + '','' + @LineFeed +' + @LineFeed +
                    '    ''            @_CollectionTime       = @CollectionTime,'' + @LineFeed +' + @LineFeed +
                    '    ''            @_RecLevel             = ' + CONVERT(VARCHAR(10),@_RecLevel + 1) + ','' + @LineFeed +' + @LineFeed +
                    '    ''            @Debug                 = ' + CONVERT(CHAR(1),@Debug) + ''' + @LineFeed +' + @LineFeed +
                    '    '';'''  + @LineFeed +
                    'FROM ' + @ParameterTableFullName  + ' p' + @LineFeed +
                    'WHERE ServerName = @@SERVERNAME' + @LineFeed +
                    'AND p.isActive = 1' + @LineFeed + 
                    'AND p.SnapSpace = 1' + @LineFeed +
                    '  AND ( ' + @LineFeed + 
                    '      p.LastSnapDateStamp IS NULL' + @LineFeed + 
                    '      OR 1 = CASE ' + @LineFeed +
                    '              WHEN upper(p.SnapInterValUnit) = ''YEAR'' AND DATEDIFF(DAY,p.LastSnapDateStamp,SYSDATETIME())/365.0 >= .95 * p.SnapIntrValValue THEN 1' + @LineFeed +
                    '              WHEN upper(p.SnapInterValUnit) = ''DAY''  AND DATEDIFF(DAY,p.LastSnapDateStamp,SYSDATETIME()) >= .95 * p.SnapIntrValValue THEN 1' + @LineFeed +
                    '              WHEN upper(p.SnapInterValUnit) = ''HOUR''  AND DATEDIFF(MINUTE,p.LastSnapDateStamp,SYSDATETIME()) / 60.0 >= .95 * p.SnapIntrValValue THEN 1' + @LineFeed +
                    '              WHEN upper(p.SnapInterValUnit) = ''MINUTE''  AND DATEDIFF(SECOND,p.LastSnapDateStamp,SYSDATETIME()) / 60.0 >= .95 * p.SnapIntrValValue THEN 1' + @LineFeed +
                    '              WHEN upper(p.SnapInterValUnit) = ''SECOND''  AND DATEDIFF(SECOND,p.LastSnapDateStamp,SYSDATETIME()) >= .95 * p.SnapIntrValValue THEN 1' + @LineFeed +
                    '              ELSE 0' + @LineFeed +
                    '             END' + @LineFeed +  
                    '  )' + @LineFeed +
                    ';'
                    ;
                    
        IF(@Debug = 1)
        BEGIN
            RAISERROR('%sNext query to run: %s',0,1,@Padding,@tsql);
            --exec [Utils].[DisplayLargeText] @TextToDisplay = @tsql;
        END;

        
        EXEC @ExecRet = sp_executesql @tsql;
        
        IF(@ExecRet <> 0)
        BEGIN
            RAISERROR('Unable to populate temporary table #Cmds2Run',12,1);
            RETURN ;
        END;  
        
        WHILE(1 = 1)
        BEGIN
        
            SET @CurrentAssetId   = NULL;
        
            SELECT 
                @CurrentAssetId         = min(CmdId)    
            FROM #Cmds2Run
            WHERE Outcome IS NULL
            ;
            
            IF(@CurrentAssetId IS NULL) -- nothing to do
            BEGIN
                BREAK; -- get out of the loop
            END;
            
            SELECT 
                @tsql                   = Tsql,
                @CurrentObjectFullName  = FullName
            FROM #Cmds2Run
            WHERE CmdId = @CurrentAssetId
            ;
            
            BEGIN TRY 
                SET @ErrorMsg       = NULL;
                SET @ErrorOccurred  = 0;
                
                IF(@Debug = 1)
                BEGIN
                    RAISERROR('%s-- Now taking care of "%s"',0,1,@Padding,@CurrentObjectFullName);
                END;
                
                EXEC @ExecRet = sp_executesql @tsql, N'@CollectionTime DATETIME2',@CollectionTime = @CollectionTime ;
                
                IF(@ExecRet <> 0)
                BEGIN
                    RAISERROR('Unable to collect space consumption for object called "%s"',12,1,@CurrentObjectFullName);
                END;
            END TRY
            BEGIN CATCH
                SET @ErrorOccurred = 1; 
                DECLARE @ErrorNumber    INT             = ERROR_NUMBER();
                DECLARE @ErrorLine      INT             = ERROR_LINE();
                DECLARE @ErrorMessage   NVARCHAR(4000)  = ERROR_MESSAGE();
                DECLARE @ErrorSeverity  INT             = ERROR_SEVERITY();
                DECLARE @ErrorState     INT             = ERROR_STATE();
                
                SET @ErrorMsg =   'Caught error #' + CAST(@ErrorNumber AS VARCHAR(10)) + /*'during XXX' + */ @LineFeed +
                                  'At line #' + CAST(@ErrorLine AS VARCHAR(10)) + @LineFeed +
                                  'With Severity ' + CAST(@ErrorSeverity AS VARCHAR(10)) + ' State ' + CAST(@ErrorState AS VARCHAR(10)) + @LineFeed +
                                  @LineFeed +
                                  'Message:' + @LineFeed +
                                  '-------' + @LineFeed +
                                  @ErrorMessage 
                                  ;
            END CATCH 
            
            -- carry on in the loop 
            UPDATE #Cmds2Run
            SET 
                Outcome = CASE WHEN @ErrorOccurred = 1 THEN 'ERROR' ELSE 'SUCCESS' END,
                LogMsg  = @ErrorMsg 
            WHERE CmdId = @CurrentAssetId 
            ;
        END;
        
        SET @tsql = 'WITH UpdatedData' + @LineFeed +
					'AS (' + @LineFeed +
					'	SELECT mo.ObjectUniqueId,max(osh.SnapDate) as LastSnap' + @LineFeed +
					'	FROM ' + @ParameterTableFullName + ' mo' + @LineFeed +
					'	INNER JOIN ' + @DestinationTableFullName + ' osh' + @LineFeed +
					'	ON mo.ObjectUniqueId = osh.ObjectUniqueId' + @LineFeed + -- This join condition will work as ObjectUniqueIds are computed columns as uses the same transformation function
					'	GROUP BY mo.ObjectUniqueId' + @LineFeed +
					')' + @LineFeed +
				    'UPDATE ' + @ParameterTableFullName + @LineFeed +
					'SET LastSnapDateStamp = ud.LastSnap' + @LineFeed +
					'FROM UpdatedData ud' + @LineFeed +
					'INNER JOIN ' + @ParameterTableFullName + ' t' + @LineFeed +
					'ON ud.ObjectUniqueId = t.ObjectUniqueId' + @LineFeed +
					'where t.LastSnapDateStamp IS NULL ' + @LineFeed +
					'OR t.LastSnapDateStamp < ud.LastSnap' + @LineFeed +
					';'
					;
		IF(@Debug = 1)
		BEGIN 
			RAISERROR(@tsql,0,1);	 
		END;
		exec sp_executesql @tsql;
        
        -- TODO: do something else with the log
        IF(EXISTS(SELECT 1 FROM #Cmds2Run WHERE Outcome <> 'SUCCESS'))
        BEGIN
            SELECT FullName, Tsql, Outcome, LogMsg FROM #Cmds2Run ;
        END;
        
        IF(OBJECT_ID('tempdb..#Cmds2Run') IS NULL)
        BEGIN
            EXEC sp_executesql N'DROP #Cmds2Run' ;
        END;

    END;
    
    if (@Debug = 1)
    BEGIN
        RAISERROR('%s-- -----------------------------------------------------------------------------------------------------------------',0,1,@Padding);
        RAISERROR('%s-- Execution of %s completed.',0,1,@Padding,@ProcedureName);
        RAISERROR('%s-- -----------------------------------------------------------------------------------------------------------------',0,1,@Padding);
    END;


END
GO


IF (@@ERROR = 0)
BEGIN
    PRINT '   PROCEDURE altered.';
END
ELSE
BEGIN
    PRINT '   Error while trying to alter procedure';
    RETURN
END;
GO

RAISERROR('-----------------------------------------------------------------------------------------------------------------',0,1);
RAISERROR('',0,1);
GO


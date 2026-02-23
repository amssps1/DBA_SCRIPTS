/*requires Schema.SpaceSnap.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [SpaceSnap].[MonitoredObjects] Creation'
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SpaceSnap].[MonitoredObjects]') AND type in (N'U'))
BEGIN
    CREATE TABLE [SpaceSnap].[MonitoredObjects] (
        ServerName          VARCHAR(512)    NOT NULL,
        DatabaseName        VARCHAR(256)    NOT NULL,
        ObjectType          VARCHAR(256)    NOT NULL,
        SchemaName          VARCHAR(256)    NOT NULL,
        ObjectName          VARCHAR(256)    NOT NULL,
        PartitionName       VARCHAR(256)    NULL,
        ColumnName          VARCHAR(256)    NULL,
        SnapRowFilter       VARCHAR(4000)   NULL,
        SnapIntervalUnit    VARCHAR(64),
        SnapIntrvalValue    SMALLINT,
        LastSnapDateStamp   DATETIME2,
        AvgDailySpaceMb     decimal(36, 2),
        AvgDailyRowsCount   BIGINT,
        SnapSpace           BIT             NOT NULL,
        isActive            BIT             NOT NULL,
        ObjectUniqueId      AS  CAST(
                                    HASHBYTES(
                                        'SHA1',
                                        ServerName + DatabaseName + ObjectType + SchemaName + ObjectName + ISNULL(PartitionName,'') + ISNULL(ColumnName,'') + ISNULL(SnapRowFilter,'')
                                    ) AS VARBINARY(20)
                                ) PERSISTED NOT NULL
    ) ON [PRIMARY]

    PRINT '    Table [SpaceSnap].[MonitoredObjects] created.'
END
ELSE
BEGIN
    PRINT '    Table [SpaceSnap].[MonitoredObjects] already exists.'
END
GO


IF  NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SpaceSnap].[MonitoredObjects]') AND name = N'PK_MonitoredObjects')
BEGIN 
    ALTER TABLE [SpaceSnap].[MonitoredObjects] ADD  CONSTRAINT [PK_MonitoredObjects] PRIMARY KEY CLUSTERED (
		ObjectUniqueId
    );
    
    PRINT '    Primary Key created.';
    
END;
GO


IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[SpaceSnap].[DF_MonitoredObjects_ServerName]') AND type = 'D')
BEGIN
    ALTER TABLE [SpaceSnap].[MonitoredObjects]
        ADD CONSTRAINT [DF_MonitoredObjects_ServerName] DEFAULT (@@SERVERNAME) FOR [ServerName]
	PRINT '   Constraint [DF_MonitoredObjects_ServerName] created.';
END;
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[SpaceSnap].[DF_MonitoredObjects_isActive]') AND type = 'D')
BEGIN
    ALTER TABLE [SpaceSnap].[MonitoredObjects]
        ADD CONSTRAINT [DF_MonitoredObjects_isActive] DEFAULT (1) FOR [isActive]
	PRINT '   Constraint [DF_MonitoredObjects_isActive] created.';
END;
GO

IF  NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[SpaceSnap].[CK_MonitoredObjects_ObjectType]') AND parent_object_id = OBJECT_ID(N'[SpaceSnap].[MonitoredObjects]'))
BEGIN 
    ALTER TABLE [SpaceSnap].[MonitoredObjects]  
        WITH CHECK 
    ADD  CONSTRAINT [CK_MonitoredObjects_ObjectType] 
    CHECK  (ObjectType IN ('TABLE','TABLE COLUMN','TABLE PARTITION','TABLE PARTITION COLUMN','INDEX','INDEX PARTITION'));
    
    PRINT '    Constraint [SpaceSnap].[CK_MonitoredObjects_ObjectType] created.';
END;
GO




PRINT '--------------------------------------------------------------------------------------------------------------';
PRINT 'Now generating CRUD procedures for [SpaceSnap].[MonitoredObjects] table';

GO

DECLARE @tsql NVARCHAR(MAX);
SET @tsql = '';
EXEC [SQLGeneration].[GetCreationSQL4TableCRUDStoredProcs] 
    @SourceSchemaName      = 'SpaceSnap',
    @SourceTableName       = 'MonitoredObjects',
    @SqlStatement		   = @tsql OUTPUT,
    @RunStatement = 1,
    @Debug = 0;

--PRINT @tsql;
GO

IF (@@ERROR = 0)
BEGIN 
    PRINT '   Generation successful.';
END
ELSE
BEGIN
    PRINT '   Generation terminated with error';
    RETURN
END;
GO   


PRINT '--------------------------------------------------------------------------------------------------------------';
PRINT '';
GO


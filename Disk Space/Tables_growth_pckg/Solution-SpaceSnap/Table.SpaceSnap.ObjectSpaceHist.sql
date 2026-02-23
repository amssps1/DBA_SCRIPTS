/*requires Schema.SpaceSnap.sql*/

PRINT '--------------------------------------------------------------------------------------------------------------'
PRINT 'Table [SpaceSnap].[ObjectSpaceHist] Creation'
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SpaceSnap].[ObjectSpaceHist]') AND type in (N'U'))
BEGIN
    CREATE TABLE [SpaceSnap].[ObjectSpaceHist] (
        SnapDate        DATETIME2       NOT NULL,
        ServerName      VARCHAR(512)    NOT NULL,
        DatabaseName    VARCHAR(256)    NOT NULL,
        ObjectType      VARCHAR(32)     NOT NULL,        
        SchemaName      VARCHAR(256)    NOT NULL,
        ObjectName      VARCHAR(256)    NOT NULL,
        PartitionName   VARCHAR(256)    NULL,
        ColumnName      VARCHAR(256)    NULL,
        RowFilter       VARCHAR(4000)   NULL,
        RowsCount       BIGINT          NULL,
        TotalSizeMb     decimal(36, 2)  NOT NULL,
        UsedSizeMb      decimal(36, 2)  NOT NULL,
        ObjectUniqueId  AS  CAST(
                                HASHBYTES(
                                    'SHA1',
                                    ServerName + DatabaseName + ObjectType + SchemaName + ObjectName + ISNULL(PartitionName,'') + ISNULL(ColumnName,'') + ISNULL(RowFilter,'')
                                ) 
                                AS VARBINARY(20)
                            ) PERSISTED  NOT NULL
    ) ON [PRIMARY]

    PRINT '    Table [SpaceSnap].[ObjectSpaceHist] created.'
END
ELSE
BEGIN
    PRINT '    Table [SpaceSnap].[ObjectSpaceHist] already exists.'
END
GO


IF  NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SpaceSnap].[ObjectSpaceHist]') AND name = N'PK_ObjectSpaceHist')
BEGIN 
    ALTER TABLE [SpaceSnap].[ObjectSpaceHist] ADD  CONSTRAINT [PK_ObjectSpaceHist] PRIMARY KEY CLUSTERED (
        SnapDate, ObjectUniqueId
    );
    
    PRINT '    Primary Key created.';
    
END;
GO

/*
TODO: ConfigurationId
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[SpaceSnap].[FK_ObjectSpaceHist_XXX]') AND parent_object_id = OBJECT_ID(N'[SpaceSnap].[ObjectSpaceHist]'))
BEGIN
    ALTER TABLE [SpaceSnap].[ObjectSpaceHist]
        ADD  CONSTRAINT [FK_ObjectSpaceHist_XXX]
            FOREIGN KEY (
                [XXX]
            )
        REFERENCES [YYYY].[ZZZ] ([XXX])
    IF @@ERROR = 0
        PRINT '   Foreign Key [FK_ObjectSpaceHist_XXX] created.'
    ELSE
    BEGIN
        PRINT '   Error while trying to create Foreign Key [FK_ObjectSpaceHist_XXX]'
        RETURN
    END
END
GO
*/

/*
IF  NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[SpaceSnap].[CK_ObjectSpaceHist_XXX]') AND parent_object_id = OBJECT_ID(N'[SpaceSnap].[ObjectSpaceHist]'))
BEGIN 
    ALTER TABLE [SpaceSnap].[ObjectSpaceHist]  
        WITH CHECK 
    ADD  CONSTRAINT [CK_ObjectSpaceHist_XXX] 
    CHECK  (ZZZ);
    
    PRINT '    Constraint [SpaceSnap].[CK_ObjectSpaceHist_XXX] created.';
END;
GO
*/

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[SpaceSnap].[DF_ObjectSpaceHist_PartitionName]') AND type = 'D')
BEGIN
    ALTER TABLE [SpaceSnap].[ObjectSpaceHist]
        ADD CONSTRAINT [DF_ObjectSpaceHist_PartitionName] DEFAULT ('') FOR [PartitionName]
	PRINT '   Constraint [DF_ObjectSpaceHist_PartitionName] created.';
END;
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[SpaceSnap].[DF_ObjectSpaceHist_ColumnName]') AND type = 'D')
BEGIN
    ALTER TABLE [SpaceSnap].[ObjectSpaceHist]
        ADD CONSTRAINT [DF_ObjectSpaceHist_ColumnName] DEFAULT ('') FOR [ColumnName]
	PRINT '   Constraint [DF_ObjectSpaceHist_ColumnName] created.';
END;
GO

IF  NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[SpaceSnap].[DF_ObjectSpaceHist_SnapDate]') AND type = 'D')
BEGIN
    ALTER TABLE [SpaceSnap].[ObjectSpaceHist]
        ADD CONSTRAINT [DF_ObjectSpaceHist_SnapDate] DEFAULT (SYSDATETIME()) FOR [SnapDate]
	PRINT '   Constraint [DF_ObjectSpaceHist_SnapDate] created.';
END;
GO

/*
PRINT '--------------------------------------------------------------------------------------------------------------';
PRINT 'Now generating CRUD procedures for [SpaceSnap].[ObjectSpaceHist] table';

GO

DECLARE @tsql NVARCHAR(MAX);
SET @tsql = '';
EXEC [SQLGeneration].[GetCreationSQL4TableCRUDStoredProcs] 
    @SourceSchemaName      = 'SpaceSnap',
    @SourceTableName       = 'ObjectSpaceHist',
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

*/


PRINT '--------------------------------------------------------------------------------------------------------------';
PRINT '';
GO


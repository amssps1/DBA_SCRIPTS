PRINT '--------------------------------------------------------------------------------------------------------------';
PRINT 'SCHEMA [SpaceSnap] CREATION';
GO 

DECLARE @SchemaName SYSNAME;
SET @SchemaName = 'SpaceSnap';

IF  NOT EXISTS (SELECT * FROM sys.schemas WHERE name = @SchemaName)
BEGIN	
    DECLARE @SQL VARCHAR(MAX);
    SET @SQL = 'CREATE SCHEMA [' + @SchemaName + '] AUTHORIZATION [dbo]'
    EXEC (@SQL)
    
	PRINT '   SCHEMA ' + @SchemaName + ' created.';
END
ELSE
	PRINT '   SCHEMA [' + @SchemaName + '] already exists.';
GO

PRINT '--------------------------------------------------------------------------------------------------------------';
PRINT '' ;
GO

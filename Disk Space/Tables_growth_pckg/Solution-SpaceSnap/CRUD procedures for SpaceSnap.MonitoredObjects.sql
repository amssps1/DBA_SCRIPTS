/*
 Find and replace every occurrences of Your_DBA_Database to the database name of your choice
 
 */

USE [Your_DBA_Database]
GO

/****** Object:  StoredProcedure [SpaceSnap].[MonitoredObjects_Delete]    Script Date: 25-07-17 11:23:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SpaceSnap].[MonitoredObjects_Delete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [SpaceSnap].[MonitoredObjects_Delete] AS' 
END
GO

ALTER PROCEDURE [SpaceSnap].[MonitoredObjects_Delete](
    @ServerName as varchar(512),
    @DatabaseName as varchar(256),
    @ObjectType as varchar(256),
    @SchemaName as varchar(256),
    @ObjectName as varchar(256),
    @PartitionName as varchar(256) = NULL ,
    @ColumnName as varchar(256) = NULL ,
    @SnapRowFilter as varchar(4000) = NULL 
)
AS
    /*----------------------------------------------------------------------------------
     *   Author  : Automated creation
     *   Created : 20170725
     *   Description : Deletes a given record in [Your_DBA_Database].[SpaceSnap].[MonitoredObjects] table
     *----------------------------------------------------------------------------------*/
BEGIN
    SET NOCOUNT ON;
    DECLARE @TranCounter  INT; -- See https://msdn.microsoft.com/fr-be/library/ms188378.aspx
    DECLARE @ObjectUniqueId    VARBINARY(20);
    SET @ObjectUniqueId = (CONVERT([varbinary](20),hashbytes('SHA1',((((((@ServerName+@DatabaseName)+@ObjectType)+@SchemaName)+@ObjectName)+isnull(@PartitionName,''))+isnull(@ColumnName,''))+isnull(@SnapRowFilter,''))));
    BEGIN TRY
        -- Delete
        DELETE [Your_DBA_Database].[SpaceSnap].[MonitoredObjects]
        WHERE 
            ObjectUniqueId = @ObjectUniqueId
        ;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage  NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState    INT;
        select @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

USE [Your_DBA_Database]
GO

/****** Object:  StoredProcedure [SpaceSnap].[MonitoredObjects_Insert]    Script Date: 25-07-17 11:23:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SpaceSnap].[MonitoredObjects_Insert]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [SpaceSnap].[MonitoredObjects_Insert] AS' 
END
GO

ALTER PROCEDURE [SpaceSnap].[MonitoredObjects_Insert](
    @ServerName as varchar(512) = @@servername,
    @DatabaseName as varchar(256),
    @ObjectType as varchar(256),
    @SchemaName as varchar(256),
    @ObjectName as varchar(256),
    @PartitionName as varchar(256) = NULL ,
    @ColumnName as varchar(256) = NULL ,
    @SnapRowFilter as varchar(4000) = NULL ,
    @SnapIntervalUnit as varchar(64) = NULL ,
    @SnapIntrvalValue as smallint = NULL ,
    @LastSnapDateStamp as datetime2 = NULL ,
    @AvgDailySpaceMb as decimal = NULL ,
    @AvgDailyRowsCount as bigint = NULL ,
    @SnapSpace as bit,
    @isActive as bit = 1
)
AS
    /*----------------------------------------------------------------------------------
     *   Author  : Automated creation
     *   Created : 20170725
     *   Description : Inserts a record into [Your_DBA_Database].[SpaceSnap].[MonitoredObjects] table
     *----------------------------------------------------------------------------------*/
BEGIN
    SET NOCOUNT ON;
    DECLARE @TranCounter  INT; -- See https://msdn.microsoft.com/fr-be/library/ms188378.aspx
    BEGIN TRY
        -- INSERT
        INSERT [Your_DBA_Database].[SpaceSnap].[MonitoredObjects](
            ServerName,
            DatabaseName,
            ObjectType,
            SchemaName,
            ObjectName,
            PartitionName,
            ColumnName,
            SnapRowFilter,
            SnapIntervalUnit,
            SnapIntrvalValue,
            LastSnapDateStamp,
            AvgDailySpaceMb,
            AvgDailyRowsCount,
            SnapSpace,
            isActive
        )
        VALUES (
            @ServerName,
            @DatabaseName,
            @ObjectType,
            @SchemaName,
            @ObjectName,
            @PartitionName,
            @ColumnName,
            @SnapRowFilter,
            @SnapIntervalUnit,
            @SnapIntrvalValue,
            @LastSnapDateStamp,
            @AvgDailySpaceMb,
            @AvgDailyRowsCount,
            @SnapSpace,
            @isActive
        );
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage  NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState    INT;
        select @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO


USE [Your_DBA_Database]
GO

/****** Object:  StoredProcedure [SpaceSnap].[MonitoredObjects_Select]    Script Date: 25-07-17 11:23:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SpaceSnap].[MonitoredObjects_Select]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [SpaceSnap].[MonitoredObjects_Select] AS' 
END
GO

ALTER PROCEDURE [SpaceSnap].[MonitoredObjects_Select](
    @ObjectUniqueId as varbinary(20)
)
AS
    /*----------------------------------------------------------------------------------
     *   Author  : Automated creation
     *   Created : 20170725
     *   Description : Deletes a given record in [Your_DBA_Database].[SpaceSnap].[MonitoredObjects] table
     *----------------------------------------------------------------------------------*/
BEGIN
    BEGIN TRY
        -- Select
        SELECT  
            ServerName,
            DatabaseName,
            ObjectType,
            SchemaName,
            ObjectName,
            PartitionName,
            ColumnName,
            SnapRowFilter,
            SnapIntervalUnit,
            SnapIntrvalValue,
            LastSnapDateStamp,
            AvgDailySpaceMb,
            AvgDailyRowsCount,
            SnapSpace,
            isActive,
            ObjectUniqueId
        FROM [Your_DBA_Database].[SpaceSnap].[MonitoredObjects]
        WHERE 
            ObjectUniqueId = @ObjectUniqueId
        ;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage  NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState    INT;
        select @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

USE [Your_DBA_Database]
GO

/****** Object:  StoredProcedure [SpaceSnap].[MonitoredObjects_Update]    Script Date: 25-07-17 11:23:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SpaceSnap].[MonitoredObjects_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [SpaceSnap].[MonitoredObjects_Update] AS' 
END
GO

ALTER PROCEDURE [SpaceSnap].[MonitoredObjects_Update](
    @ServerName as varchar(512) = @@servername,
    @DatabaseName as varchar(256),
    @ObjectType as varchar(256),
    @SchemaName as varchar(256),
    @ObjectName as varchar(256),
    @PartitionName as varchar(256) = NULL ,
    @ColumnName as varchar(256) = NULL ,
    @SnapRowFilter as varchar(4000) = NULL ,
    @SnapIntervalUnit as varchar(64) = NULL ,
    @SnapIntrvalValue as smallint = NULL ,
    @LastSnapDateStamp as datetime2 = NULL ,
    @AvgDailySpaceMb as decimal = NULL ,
    @AvgDailyRowsCount as bigint = NULL ,
    @SnapSpace as bit,
    @isActive as bit = 1
)
AS
    /*----------------------------------------------------------------------------------
     *   Author  : Automated creation
     *   Created : 20170725
     *   Description : Updates a given record in [Your_DBA_Database].[SpaceSnap].[MonitoredObjects] table
     *----------------------------------------------------------------------------------*/
BEGIN
    SET NOCOUNT ON;
    DECLARE @TranCounter  INT; -- See https://msdn.microsoft.com/fr-be/library/ms188378.aspx
    DECLARE @ObjectUniqueId    VARBINARY(20);
    SET @ObjectUniqueId = (CONVERT([varbinary](20),hashbytes('SHA1',((((((@ServerName+@DatabaseName)+@ObjectType)+@SchemaName)+@ObjectName)+isnull(@PartitionName,''))+isnull(@ColumnName,''))+isnull(@SnapRowFilter,''))));
    BEGIN TRY
        -- UPDATE
        UPDATE [Your_DBA_Database].[SpaceSnap].[MonitoredObjects]
            SET
                ServerName = ISNULL(@ServerName, ServerName),
                DatabaseName = ISNULL(@DatabaseName, DatabaseName),
                ObjectType = ISNULL(@ObjectType, ObjectType),
                SchemaName = ISNULL(@SchemaName, SchemaName),
                ObjectName = ISNULL(@ObjectName, ObjectName),
                PartitionName = ISNULL(@PartitionName, PartitionName),
                ColumnName = ISNULL(@ColumnName, ColumnName),
                SnapRowFilter = ISNULL(@SnapRowFilter, SnapRowFilter),
                SnapIntervalUnit = ISNULL(@SnapIntervalUnit, SnapIntervalUnit),
                SnapIntrvalValue = ISNULL(@SnapIntrvalValue, SnapIntrvalValue),
                LastSnapDateStamp = ISNULL(@LastSnapDateStamp, LastSnapDateStamp),
                AvgDailySpaceMb = ISNULL(@AvgDailySpaceMb, AvgDailySpaceMb),
                AvgDailyRowsCount = ISNULL(@AvgDailyRowsCount, AvgDailyRowsCount),
                SnapSpace = ISNULL(@SnapSpace, SnapSpace),
                isActive = ISNULL(@isActive, isActive)
        WHERE 
            ObjectUniqueId = @ObjectUniqueId
        ;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage  NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState    INT;
        select @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

USE [Your_DBA_Database]
GO

/****** Object:  StoredProcedure [SpaceSnap].[MonitoredObjects_Upsert]    Script Date: 25-07-17 11:24:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SpaceSnap].[MonitoredObjects_Upsert]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [SpaceSnap].[MonitoredObjects_Upsert] AS' 
END
GO

ALTER PROCEDURE [SpaceSnap].[MonitoredObjects_Upsert](
    @ServerName as varchar(512) = @@servername,
    @DatabaseName as varchar(256),
    @ObjectType as varchar(256),
    @SchemaName as varchar(256),
    @ObjectName as varchar(256),
    @PartitionName as varchar(256) = NULL ,
    @ColumnName as varchar(256) = NULL ,
    @SnapRowFilter as varchar(4000) = NULL ,
    @SnapIntervalUnit as varchar(64) = NULL ,
    @SnapIntrvalValue as smallint = NULL ,
    @LastSnapDateStamp as datetime2 = NULL ,
    @AvgDailySpaceMb as decimal = NULL ,
    @AvgDailyRowsCount as bigint = NULL ,
    @SnapSpace as bit,
    @isActive as bit = 1
)
AS
    /*----------------------------------------------------------------------------------
     *   Author  : Automated creation
     *   Created : 20170725
     *   Description : Inserts or updates a record into [Your_DBA_Database].[SpaceSnap].[MonitoredObjects] table
     *----------------------------------------------------------------------------------*/
BEGIN
    SET NOCOUNT ON;
    DECLARE @TranCounter  INT; -- See https://msdn.microsoft.com/fr-be/library/ms188378.aspx
    DECLARE @ObjectUniqueId    VARBINARY(20);
    SET @ObjectUniqueId = (CONVERT([varbinary](20),hashbytes('SHA1',((((((@ServerName+@DatabaseName)+@ObjectType)+@SchemaName)+@ObjectName)+isnull(@PartitionName,''))+isnull(@ColumnName,''))+isnull(@SnapRowFilter,''))));
    BEGIN TRY
        -- Choose between INSERT AND UPDATE
        IF( 0 = (SELECT COUNT(*) FROM [Your_DBA_Database].[SpaceSnap].[MonitoredObjects] WHERE 
                ObjectUniqueId = @ObjectUniqueId
            )
        )
        BEGIN
            EXEC [Your_DBA_Database].[SpaceSnap].[MonitoredObjects_Insert]
                      @ServerName = @ServerName,
                      @DatabaseName = @DatabaseName,
                      @ObjectType = @ObjectType,
                      @SchemaName = @SchemaName,
                      @ObjectName = @ObjectName,
                      @PartitionName = @PartitionName,
                      @ColumnName = @ColumnName,
                      @SnapRowFilter = @SnapRowFilter,
                      @SnapIntervalUnit = @SnapIntervalUnit,
                      @SnapIntrvalValue = @SnapIntrvalValue,
                      @LastSnapDateStamp = @LastSnapDateStamp,
                      @AvgDailySpaceMb = @AvgDailySpaceMb,
                      @AvgDailyRowsCount = @AvgDailyRowsCount,
                      @SnapSpace = @SnapSpace,
                      @isActive = @isActive
            ;
        END;
        ELSE
        BEGIN
            EXEC [Your_DBA_Database].[SpaceSnap].[MonitoredObjects_Update]
                      @ServerName = @ServerName,
                      @DatabaseName = @DatabaseName,
                      @ObjectType = @ObjectType,
                      @SchemaName = @SchemaName,
                      @ObjectName = @ObjectName,
                      @PartitionName = @PartitionName,
                      @ColumnName = @ColumnName,
                      @SnapRowFilter = @SnapRowFilter,
                      @SnapIntervalUnit = @SnapIntervalUnit,
                      @SnapIntrvalValue = @SnapIntrvalValue,
                      @LastSnapDateStamp = @LastSnapDateStamp,
                      @AvgDailySpaceMb = @AvgDailySpaceMb,
                      @AvgDailyRowsCount = @AvgDailyRowsCount,
                      @SnapSpace = @SnapSpace,
                      @isActive = @isActive
            ;
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage  NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState    INT;
        select @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO


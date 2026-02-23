use master

DECLARE @DBName nvarchar(50)
SET @DBName = 'DM_Actividade' 

DECLARE @RC int

EXEC @RC = sp_detach_db @DBName

DECLARE @NewPath nvarchar(1000)
SET @NewPath = 'E:\Data\Microsoft SQL Server\Data\';

DECLARE @OldPath nvarchar(1000)
SET @OldPath = 'H:\DATA\';

DECLARE @DBFileName nvarchar(100)
SET @DBFileName = @DBName + '.mdf';

DECLARE @LogFileName nvarchar(100)
SET @LogFileName = @DBName + '_log.ldf';

DECLARE @SRCData nvarchar(1000)
SET @SRCData = @OldPath + @DBFileName;

DECLARE @SRCLog nvarchar(1000)
SET @SRCLog = @OldPath + @LogFileName;

DECLARE @DESTData nvarchar(1000)
SET @DESTData = @NewPath + @DBFileName;

DECLARE @DESTLog nvarchar(1000)
SET @DESTLog = @NewPath + @LogFileName;

DECLARE @FILEPATH nvarchar(1000);
DECLARE @LOGPATH nvarchar(1000);
SET @FILEPATH = N'xcopy /Y "' + @SRCData + N'" "' + @NewPath + '"';
SET @LOGPATH = N'xcopy /Y "' + @SRCLog + N'" "' + @NewPath + '"';

exec xp_cmdshell @FILEPATH;
exec xp_cmdshell @LOGPATH;

EXEC @RC = sp_attach_db @DBName, @DESTData, @DESTLog

go
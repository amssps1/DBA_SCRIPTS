

-- Cleans msdb job history older than 60 days
SET NOCOUNT ON;
-- Is it Sunday yet?
IF (SELECT 1 & POWER(2, DATEPART(weekday, GETDATE())-1)) > 0
BEGIN
	DECLARE @date DATETIME
	SET @date = GETDATE()-90
	EXEC msdb.dbo.sp_purge_jobhistory @oldest_date=@date;
-- Delete Backup history
	exec msdb.dbo.sp_delete_backuphistory @date;
END
ELSE
BEGIN
	PRINT '** Skipping: Today is not Sunday - ' + CONVERT(VARCHAR, GETDATE())
END;
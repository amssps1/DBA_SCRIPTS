-- Grani

DECLARE @DatabaseName NVARCHAR(128)
DECLARE @SQL NVARCHAR(MAX)

DECLARE db_cursor CURSOR FOR
SELECT name 
FROM sys.databases 
WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','LCM','LCMReports','cofcc_hds','ReportServer','ReportServerTempDB','SSISDB') 
AND state_desc = 'ONLINE'  -- Exclude databases that are offline


OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @DatabaseName

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = 'ALTER DATABASE [' + @DatabaseName + '] SET COMPATIBILITY_LEVEL = 160;'
    EXEC sp_executesql @SQL

    FETCH NEXT FROM db_cursor INTO @DatabaseName
END

CLOSE db_cursor
DEALLOCATE db_cursor
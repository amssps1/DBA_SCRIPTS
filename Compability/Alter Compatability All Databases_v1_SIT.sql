-- Sitsql1 / sitsql2

DECLARE @DatabaseName NVARCHAR(128)
DECLARE @SQL NVARCHAR(MAX)

DECLARE db_cursor CURSOR FOR
SELECT name 
FROM sys.databases 
WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','LCM','LCMReports','cofcc_hds','ReportServer','ReportServerTempDB','SSISDB','RHInternalApp','RH','Armada','RGPD_HU',
'RGPD_PL','RGPD_PT','RGPD_SK','PBIReportServer','PBIReportServerTempDB','ReportServer$INST2','ReportServer$INST2TempDB','EDAvalDesemp') 
AND state_desc = 'ONLINE'  -- Exclude databases that are offline
and  [is_read_only] <> 1

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
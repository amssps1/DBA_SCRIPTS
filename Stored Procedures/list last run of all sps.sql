-- Create a temporary table to store results
CREATE TABLE #AllSPExecutionStats (
    DBName SYSNAME,
    SPName NVARCHAR(128),
    LastExecutionTime DATETIME,
	Runsperday int
);

-- Iterate through all databases
DECLARE @DBName NVARCHAR(128);
DECLARE @SQL NVARCHAR(MAX);

DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE state_desc = 'ONLINE' AND name NOT IN ('master', 'tempdb', 'model', 'msdb'); -- Exclude system databases

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DBName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = '
        USE ' + QUOTENAME(@DBName) + ';

        INSERT INTO #AllSPExecutionStats (DBName, SPName, LastExecutionTime,Runsperday)
        SELECT 
            DB_NAME() AS DBName,
            OBJECT_NAME(object_id) AS SPName,
           max(last_execution_time) AS LastExecutionTime,
		   count(*) as Runsperday
        FROM sys.dm_exec_procedure_stats
		 group by OBJECT_NAME(object_id);';

    EXEC sp_executesql @SQL;

    FETCH NEXT FROM db_cursor INTO @DBName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

-- Retrieve the results
SELECT DBName, SPName,Runsperday, LastExecutionTime
FROM #AllSPExecutionStats
ORDER BY DBName, SPName;

-- Drop the temporary table
DROP TABLE #AllSPExecutionStats;


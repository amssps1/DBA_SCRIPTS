
SELECT 
    CAST(@@SERVERNAME AS NVARCHAR(255)) COLLATE Latin1_General_CI_AS + ',' + CHAR(9) + 
    d.name COLLATE Latin1_General_CI_AS + ',' +   CHAR(9) + 
    CONVERT(VARCHAR, d.create_date, 120)  + CHAR(9)  
 --   d.state_desc COLLATE Latin1_General_CI_AS + ',' + CHAR(9)  

AS ExcelRow
FROM sys.databases d
WHERE d.database_id > 4 -- Exclude system databases
AND state_desc = 'ONLINE'  -- Only online databases
ORDER BY d.name;

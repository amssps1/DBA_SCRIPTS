SELECT 
    db.name AS                                   [Database Name], 
    mf.name AS                                   [Logical Name], 
    mf.type_desc AS                              [File Type], 
    mf.physical_name AS                          [Path], 
    CAST(
        (mf.Size * 8
        ) / 1024.0 AS DECIMAL(18, 1)) AS         [Initial Size (MB)], 
    'By '+IIF(
            mf.is_percent_growth = 1, CAST(mf.growth AS VARCHAR(10))+'%', CONVERT(VARCHAR(30), CAST(
        (mf.growth * 8
        ) / 1024.0 AS DECIMAL(18, 1)))+' MB') AS [Autogrowth], 
    IIF(mf.max_size = 0, 'No growth is allowed', IIF(mf.max_size = -1, 'Unlimited', CAST(
        (
                CAST(mf.max_size AS BIGINT) * 8
        ) / 1024 AS VARCHAR(30))+' MB')) AS      [MaximumSize]
FROM 
     sys.master_files AS mf
     INNER JOIN sys.databases AS db ON
            db.database_id = mf.database_id


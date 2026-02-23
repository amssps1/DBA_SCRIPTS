SELECT 
    r.session_id,
    r.command,
    r.percent_complete,
    r.start_time,
    r.estimated_completion_time / 1000 / 60 AS Est_Minutes_Remaining,
    r.estimated_completion_time / 1000 AS Est_Sec_Remaining,
    r.total_elapsed_time / 1000 / 60 AS Elapsed_Minutes,
    r.estimated_completion_time / 1000 / 60.0 + r.total_elapsed_time / 1000 / 60.0 AS Est_Total_Minutes
FROM sys.dm_exec_requests r
WHERE r.command LIKE 'BACKUP%';

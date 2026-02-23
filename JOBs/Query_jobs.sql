SELECT 
    j.job_id,
    j.name AS JobName,
    s.schedule_id,
    s.name AS ScheduleName,
    js.next_run_date,
    js.next_run_time
FROM 
    msdb.dbo.sysjobs j
INNER JOIN 
    msdb.dbo.sysjobschedules js ON j.job_id = js.job_id
INNER JOIN 
    msdb.dbo.sysschedules s ON js.schedule_id = s.schedule_id
	WHERE  j.name='VG_MigraContactosLCM_Catalog'
ORDER BY 
    j.name, s.name;




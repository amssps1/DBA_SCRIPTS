SELECT login_name [Login] , MAX(login_time) AS [Last Login Time]
FROM sys.dm_exec_sessions
GROUP BY login_name;



select DISTINCT login_time, host_name, program_name, login_name,l.database_id,d.name as DBname from
(SELECT sys.dm_exec_sessions.*,
RANK() OVER(PARTITION BY login_name ORDER BY login_time DESC) as rnk
FROM sys.dm_exec_sessions) l
inner join sys.databases d on l.database_id = d.database_id
--where l.rnk = 1 and
 where d.name='Cofinet'
ORDER BY l.login_time DESC


----
---start of running queries
----
select
(er.total_elapsed_time) as elap_ms,
(er.total_elapsed_time/1000) as elap_s,
(er.total_elapsed_time/1000) /60 as elap_m, 
es.session_id as spid,
(case when len(es.host_name)=0 then 'n/a' 
       else es.host_name 
       end 
       ) as hostname,
es.host_process_id as os_pid,
es.login_name as username,
db_name(er.database_id) as db,
substring (qt.text,(er.statement_start_offset/2) + 1,  
  ((case when er.statement_end_offset = -1  
  then len(convert(nvarchar(max), qt.text)) * 2  
  else er.statement_end_offset 
  end - er.statement_start_offset)/2) + 1) as [query],
qt.text as [parent_query],
er.status,
er.command as cmd,
es.program_name as prog,
er.start_time,
--qp.query_plan,
er.wait_type,
er.cpu_time,
er.logical_reads,
er.reads,
er.writes,
er.blocking_session_id,
er.open_transaction_count,
er.last_wait_type,
er.percent_complete,
er.sql_handle,
db_name(qt.dbid) as db,
object_name(qt.objectid,qt.dbid) as obj,
er.plan_handle as plan_handle
from sys.dm_exec_requests as er 
inner join sys.dm_exec_sessions as es on es.session_id = er.session_id 
inner join sys.sysprocesses as ps on ps.spid=es.session_id
cross apply sys.dm_exec_sql_text(er.sql_handle) as qt 
cross apply sys.dm_exec_query_plan(er.plan_handle) qp 
where es.is_user_process=1  
and es.session_id not in (@@spid) 
--and len(es.host_name) > 1
--and es.program_name not like 'sql server profiler%'
order by elap_ms desc
----
---end of running queries
----

----
---start of blocking queries
----
select 
    es.host_process_id as pid_os,
       er.session_id as blocked_process_id,
       (select st3.text as [text()] 
             from sys.dm_exec_requests as er3 cross apply sys.dm_exec_sql_text(er3.sql_handle) as st3
             where er3.session_id = er.session_id 
             for xml path(''), type) as blocked_buffer,
       es.last_request_start_time as blocked_last_start,
       er.total_elapsed_time/1000 total_elapsed_time_seconds,
       er.blocking_session_id as blocking_process_id, 
       (select st4.text as [text()] 
             from sys.dm_exec_requests as er4 cross apply sys.dm_exec_sql_text(er4.sql_handle) as st4
             where er4.session_id = er.blocking_session_id 
             for xml path(''), type) as blocking_buffer,
       es2.last_request_start_time as blocking_last_start,
       db_name(er.database_id) as dbname, 
--     er.status as status, 
       es.host_name as blocked_host_name,
       es.program_name as blocked_program_name, 
       er.command as blocked_cmd,
       es.login_name as blocked_login_name,
       es2.host_name as blocking_host_name,
       es2.program_name as blocking_program_name,     
       (select er2.command from sys.dm_exec_requests as er2 where er2.session_id = er.blocking_session_id) as blocking_cmd, 
       es2.login_name as blocking_login_name,
--     er.open_transaction_count as trans_open_for_request, 
--     er.row_count,
       er.wait_resource as waitresource,       
       er.wait_type as waittype, 
       er.wait_time as waittime, 
       er.scheduler_id as scheduler,
       er.cpu_time cpu_time,
       er.sql_handle,
       db_name(t.dbid) as db,
       object_name(t.objectid,t.dbid) as obj,
       er.plan_handle as plan_handle
from sys.dm_exec_requests as er
       cross apply sys.dm_exec_sql_text(er.sql_handle) t
inner join sys.dm_exec_sessions as es
       on er.session_id = es.session_id
inner join sys.dm_exec_sessions as es2
       on er.blocking_session_id = es2.session_id
where er.status = N'suspended' and er.session_id <> @@spid
order by er.total_elapsed_time desc
go
----
---end of blocking queries
----


----
	-----start of backup/restore report
	------
	--select start_time,
	--	   (total_elapsed_time/1000/60) as minutesrunning,
	--	   percent_complete,
	--	   command,
	--	   b.name as databasename,
	--			  -- master will appear here because the database is not accesible yet.
	--	   dateadd(ms,estimated_completion_time,getdate()) as estimatedcompletiontime,
	--	  (estimated_completion_time/1000/60) as minutestofinish
	--from  sys.dm_exec_requests a
	--		  inner join sys.databases b on a.database_id = b.database_id
	--where command like '%restore%'
	--		  or command like '%backup%'
	--		  and estimated_completion_time > 0
	------
	-----end of backup/restore report
----
--checkpoint;
--kill 69
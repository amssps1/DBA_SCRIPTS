SELECT s.session_id,
 r.STATUS,
r.blocking_session_id,
r.wait_type,
wait_resource,
r.wait_time / (1000 * 60) 'wait_time(Min)',
r.cpu_time,
r.logical_reads,
r.reads,
r.writes,
r.total_elapsed_time / (1000 * 60) 'total_elapsed_time(Min)',
Substring(st.TEXT,(r.statement_start_offset / 2) + 1,
((CASE r.statement_end_offset
WHEN -1
THEN Datalength(st.TEXT)
ELSE r.statement_end_offset
END - r.statement_start_offset) / 2) + 1) AS statement_text,
Coalesce(Quotename(Db_name(st.dbid)) + N'.' + Quotename(Object_schema_name(st.objectid, st.dbid)) + N'.' +
Quotename(Object_name(st.objectid, st.dbid)), '') AS command_text,
r.command,
qp.query_plan,
s.login_name,
s.host_name,
s.program_name,
s.last_request_end_time,
s.login_time,
r.open_transaction_count
FROM sys.dm_exec_sessions AS s
JOIN sys.dm_exec_requests AS r
ON r.session_id = s.session_id
CROSS APPLY sys.Dm_exec_sql_text(r.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) AS qp
WHERE r.session_id != @@SPID
ORDER BY session_id 

--
--KILL 96
--kill 802

SELECT
owt.session_id,
owt.exec_context_id,
owt.wait_duration_ms,
owt.wait_type,
owt.blocking_session_id,
owt.resource_description,
est.text,
es.program_name,
eqp.query_plan,
es.cpu_time,
es.memory_usage
FROM
sys.dm_os_waiting_tasks owt
INNER JOIN sys.dm_exec_sessions es ON 
owt.session_id = es.session_id
INNER JOIN sys.dm_exec_requests er
ON es.session_id = er.session_id
OUTER APPLY sys.dm_exec_sql_text (er.sql_handle) est
OUTER APPLY sys.dm_exec_query_plan (er.plan_handle) eqp
WHERE es.is_user_process = 1
ORDER BY owt.session_id, owt.exec_context_id




--kill 163

SELECT  
	DB_NAME(st.dbid) DatabaseName,
	OBJECT_SCHEMA_NAME(st.objectid,dbid) SchemaName,
	OBJECT_NAME(st.objectid,dbid) StoredProcedure,
	MAX(cp.usecounts) ExecutionCount
FROM sys.dm_exec_cached_plans cp CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE DB_NAME(st.dbid) IS NOT NULL 
	AND cp.objtype = 'proc'
	AND OBJECT_NAME(st.objectid, dbid) LIKE 'COM_GET_HistoricoContactoNC'
GROUP BY cp.plan_handle, DB_NAME(st.dbid),
	OBJECT_SCHEMA_NAME(objectid,st.dbid),
	OBJECT_NAME(objectid,st.dbid)
ORDER BY MAX(cp.usecounts) DESC
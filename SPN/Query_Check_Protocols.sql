
USE [master]
GO
SELECT COUNT(auth_scheme) as sessions_count, net_transport, auth_scheme 
FROM sys.dm_exec_connections
GROUP BY net_transport, auth_scheme
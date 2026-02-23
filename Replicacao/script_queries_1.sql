EXEC sp_helpdistributor;  
EXEC sp_helpdistributiondb;  
EXEC sp_helpdistpublisher;

---
USE Distribution 
GO 
select * from MSpublications
--

USE Distribution 
GO 
select * from MSpublications



-- Replication_CMDS


SELECT
     P.[publication]   AS [Publication Name]
    ,A.[publisher_db]  AS [Database Name]
    ,A.[article]       AS [Article Name]
    ,A.[source_owner]  AS [Schema]
    ,A.[source_object] AS [Object]
FROM
    [distribution].[dbo].[MSarticles] AS A
    INNER JOIN [distribution].[dbo].[MSpublications] AS P
        ON (A.[publication_id] = P.[publication_id])
ORDER BY
    P.[publication], A.[article];
	
	----
	
-- Sttaus da replicacao

SELECT publisher,
publisher_db,
publication_id,
CASE publication_type
    WHEN 0 then '0 - Transactional publication'
    WHEN 1 then '1 - Snapshot publication'
    WHEN 2 then '2 - Merge publication'
END AS publication_type_desc,
publication,
CASE agent_type
    WHEN 1 then '1 - Snapshot Agent'
    WHEN 2 then '2 - Log Reader Agent'
    WHEN 3 then '3 - Distribution Agent'
    WHEN 4 then '4 - Merge Agent'
    WHEN 9 then '9 - Queue Reader Agent'
END AS agent_type,
agent_name,
CASE status
    WHEN 1 THEN '1 - Started'
    WHEN 2 THEN '2 - Succeeded'
    WHEN 3 THEN '3 - In progress'
    WHEN 4 THEN '4 - Idle'
    WHEN 5 THEN '5 - Retrying'
    WHEN 6 THEN '6 - Failed'
END AS agent_status,
RIGHT('0' + CAST(cur_latency / 3600 AS VARCHAR),2) + ':' +
RIGHT('0' + CAST((cur_latency / 60) % 60 AS VARCHAR),2) + ':' +
RIGHT('0' + CAST(cur_latency % 60 AS VARCHAR),2) AS cur_latency,
RIGHT('0' + CAST(worst_latency / 3600 AS VARCHAR),2) + ':' +
RIGHT('0' + CAST((worst_latency / 60) % 60 AS VARCHAR),2) + ':' +
RIGHT('0' + CAST(worst_latency % 60 AS VARCHAR),2) AS max_latency,
RIGHT('0' + CAST(best_latency / 3600 AS VARCHAR),2) + ':' +
RIGHT('0' + CAST((best_latency / 60) % 60 AS VARCHAR),2) + ':' +
RIGHT('0' + CAST(best_latency % 60 AS VARCHAR),2) AS min_latency,
RIGHT('0' + CAST(avg_latency / 3600 AS VARCHAR),2) + ':' +
RIGHT('0' + CAST((avg_latency / 60) % 60 AS VARCHAR),2) + ':' +
RIGHT('0' + CAST(avg_latency % 60 AS VARCHAR),2) AS avg_latency,
last_distsync AS last_time_dist_agent_run,
isagentrunningnow AS is_agent_running_now, 
agentstoptime AS agent_stop_time,
CASE warning
    WHEN 1 THEN 'Expiration'
    WHEN 2 THEN 'Latency'
    WHEN 4 THEN 'Merge expiration '
    WHEN 16 THEN 'Merge slow run duration '
    WHEN 32 THEN 'Merge fast run speed '
    WHEN 64 THEN 'Merge slow run speed'
END AS warning,
CASE retention_period_unit
    WHEN 1 THEN CAST(retention AS VARCHAR)+' Week'
    WHEN 2 THEN CAST(retention AS VARCHAR)+' Month'
    WHEN 3 THEN CAST(retention AS VARCHAR)+' Year'
END AS pub_retention_period,
distdb AS distribution_db
FROM distribution.dbo.MSreplication_monitordata
WHERE publisher_db = 'acm_db'
AND publication IN ('ALL','Pub_ACM_DB')
ORDER BY publisher, 
agent_type, 
publication




----------------

-- Todos os objectos em replicacao

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

IF EXISTS (SELECT 1 FROM master..sysdatabases WHERE name = 'Distribution')
BEGIN
	-- Get the publication name based on article 
	SELECT DISTINCT  
		 p.publication								AS Publication_Name
		,srv.srvname								AS Publication_Server  
		,a.publisher_db								AS Publication_Database
		,a.article									AS Publication_Table_Name
		,ss.srvname									AS Subscription_Server  
		,s.subscriber_db							AS Subscription_Database
		,a.destination_object 						AS Subscription_Table_Name
		,da.subscriber_login				 		AS Subscription_Login
		,da.name							 		AS Distribution_Agent_Job_Name
	FROM Distribution..MSArticles a  
	JOIN Distribution..MSpublications p 
		ON a.publication_id = p.publication_id 
	JOIN Distribution..MSsubscriptions s 
		ON p.publication_id = s.publication_id 
	JOIN master..sysservers ss 
		ON s.subscriber_id = ss.srvid 
	JOIN master..sysservers srv 
		ON srv.srvid = p.publisher_id 
	JOIN Distribution..MSdistribution_agents da 
		ON da.publisher_id = p.publisher_id  
		AND da.subscriber_id = s.subscriber_id 
	ORDER BY 1,2,3 
END

----


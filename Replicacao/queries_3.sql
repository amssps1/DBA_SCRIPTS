


USE acm_db
GO
EXEC sp_dropsubscription @publication = N'Pub_ACM_DB', @article = N'all', @subscriber = N'all', @destination_db = N'all'


	
use acm_db;
go
 
exec sp_droppublication @publication='Pub_ACM_DB',
                        @ignore_distributor=1

--Step 2: Drop the distributor database with @ignore_distributor=1

	
use master;
go
exec sp_replicationdboption @dbname='acm_db',
                            @optname = 'publish',
                            @value = 'false'
 
 use distribution
exec sp_dropdistributor @no_checks=1, @ignore_distributor = 1

--Step 3: Finally you can run sp_removedbreplication, just to confirm that all went smoothly
	
use master;
go
exec sp_removedbreplication @dbname='Pub_ACM_DB'


-------------------

EXEC sp_helpdistributor;  
EXEC sp_helpdistributiondb;  
EXEC sp_helpdistpublisher;


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
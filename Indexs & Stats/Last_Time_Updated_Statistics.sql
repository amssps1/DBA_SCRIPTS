SELECT
  OBJECT_NAME(object_id) 'Table Name',
  'Index Name' = QUOTENAME(s.name, '['),
  'AUTOSTATS' =
               CASE s.no_recompute
                 WHEN 1 THEN 'OFF'
                 ELSE 'ON'
               END,
  AUTO_CREATED,
  'Last Updated' = STATS_DATE(object_id, s.stats_id)
FROM sys.stats s
WHERE OBJECTPROPERTY(OBJECT_ID, 'IsSystemTable') = 0
AND OBJECT_NAME(object_id) NOT LIKE 'ifts%'      --  COMMENT OUT IF WANT TO SEE FULLTEXT INDEXES
AND OBJECT_NAME(object_id) NOT LIKE 'fulltext%'  --  COMMENT OUT IF WANT TO SEE FULLTEXT INDEXES
AND AUTO_CREATED = 0                             -- COMMENT OUT IF WANT TO SEE AUTO CREATED STATS AS WELL
-- and object_name(object_id) = 'LOCATION'  -- PARTICULAR TABLE
ORDER BY [Last Updated] DESC


--sp_updatestats
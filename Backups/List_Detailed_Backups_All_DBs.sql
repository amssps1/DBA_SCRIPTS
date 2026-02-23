SELECT T1.name
	,T3_full.full_backup_start_date
	,T3_full.full_backup_finish_date
	,T3_full.full_Duration
	,t3_full.full_backup_size
	,t3_full.full_physical_device_name
	,T3_diff.diff_backup_start_date
	,T3_diff.diff_backup_finish_date
	,T3_diff.diff_Duration
	,t3_diff.diff_backup_size
	,t3_diff.diff_physical_device_name
	,T3_log.log_backup_start_date
	,T3_log.log_backup_finish_date
	,T3_log.log_Duration
	,t3_log.log_backup_size
	,t3_log.log_physical_device_name
FROM master..sysdatabases T1
LEFT OUTER JOIN (
	SELECT database_name
		,MAX(full_backup_start_date) AS full_backup_start_date
		,MAX(full_backup_finish_date) AS full_backup_finish_date
		,MAX(diff_backup_start_date) AS diff_backup_start_date
		,MAX(diff_backup_finish_date) AS diff_backup_finish_date
		,MAX(log_backup_start_date) AS log_backup_start_date
		,MAX(log_backup_finish_date) AS log_backup_finish_date
	FROM (
		SELECT msdb.dbo.backupset.database_name
			,CASE 
				WHEN msdb.dbo.backupset.type = 'D'
					THEN MAX(msdb.dbo.backupset.backup_start_date)
				ELSE NULL
				END AS full_backup_start_date
			,CASE 
				WHEN msdb.dbo.backupset.type = 'D'
					THEN MAX(msdb.dbo.backupset.backup_finish_date)
				ELSE NULL
				END AS full_backup_finish_date
			,CASE 
				WHEN msdb.dbo.backupset.type = 'I'
					THEN MAX(msdb.dbo.backupset.backup_start_date)
				ELSE NULL
				END AS diff_backup_start_date
			,CASE 
				WHEN msdb.dbo.backupset.type = 'I'
					THEN MAX(msdb.dbo.backupset.backup_finish_date)
				ELSE NULL
				END AS diff_backup_finish_date
			,CASE 
				WHEN msdb.dbo.backupset.type = 'L'
					THEN MAX(msdb.dbo.backupset.backup_start_date)
				ELSE NULL
				END AS log_backup_start_date
			,CASE 
				WHEN msdb.dbo.backupset.type = 'L'
					THEN MAX(msdb.dbo.backupset.backup_finish_date)
				ELSE NULL
				END AS log_backup_finish_date
		FROM msdb.dbo.backupset
		GROUP BY msdb.dbo.backupset.database_name
			,msdb.dbo.backupset.type
		) max_date_subset
	GROUP BY database_name
	) T2 ON T1.name = T2.database_name
LEFT OUTER JOIN (
	SELECT msdb.dbo.backupset.database_name
		,msdb.dbo.backupset.backup_start_date AS full_backup_start_date
		,msdb.dbo.backupset.backup_finish_date AS full_backup_finish_date
		,DATEDIFF(second, msdb.dbo.backupset.backup_start_date, msdb.dbo.backupset.backup_finish_date) AS full_Duration
		,msdb.dbo.backupset.backup_size AS full_backup_size
		,msdb.dbo.backupmediafamily.physical_device_name AS full_physical_device_name
	FROM msdb.dbo.backupmediafamily
	INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
	) T3_full ON T2.database_name = T3_full.database_name
	AND t2.full_backup_start_date = T3_full.full_backup_start_date
	AND t2.full_backup_finish_date = T3_full.full_backup_finish_date
LEFT OUTER JOIN (
	SELECT msdb.dbo.backupset.database_name
		,msdb.dbo.backupset.backup_start_date AS diff_backup_start_date
		,msdb.dbo.backupset.backup_finish_date AS diff_backup_finish_date
		,DATEDIFF(second, msdb.dbo.backupset.backup_start_date, msdb.dbo.backupset.backup_finish_date) AS diff_Duration
		,msdb.dbo.backupset.backup_size AS diff_backup_size
		,msdb.dbo.backupmediafamily.physical_device_name AS diff_physical_device_name
	FROM msdb.dbo.backupmediafamily
	INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
	) T3_diff ON T2.database_name = T3_diff.database_name
	AND t2.diff_backup_start_date = T3_diff.diff_backup_start_date
	AND t2.diff_backup_finish_date = T3_diff.diff_backup_finish_date
LEFT OUTER JOIN (
	SELECT msdb.dbo.backupset.database_name
		,msdb.dbo.backupset.backup_start_date AS log_backup_start_date
		,msdb.dbo.backupset.backup_finish_date AS log_backup_finish_date
		,DATEDIFF(second, msdb.dbo.backupset.backup_start_date, msdb.dbo.backupset.backup_finish_date) AS log_Duration
		,msdb.dbo.backupset.backup_size AS log_backup_size
		,msdb.dbo.backupmediafamily.physical_device_name AS log_physical_device_name
	FROM msdb.dbo.backupmediafamily
	INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
	) T3_log ON T2.database_name = T3_log.database_name
	AND t2.log_backup_start_date = T3_log.log_backup_start_date
	AND t2.log_backup_finish_date = T3_log.log_backup_finish_date
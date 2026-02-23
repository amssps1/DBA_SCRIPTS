


----
-- Artemis
---
--- FAZ BACKUP A USER DBS
----
--- 


DECLARE @Baksql VARCHAR(8000)
DECLARE @Baksql_ver VARCHAR(8000)
DECLARE @BackupFolder_sys VARCHAR(100)
DECLARE @BackupFolder_user VARCHAR(100)

DECLARE @BackupFile VARCHAR(100)
DECLARE @BAK_PATH VARCHAR(4000)
DEclare @BackupDate varchar(100)
DEclare @Size varchar(100)
DECLARE @Recovery_Model VARCHAR(40)


-- Setting value of backup date and folder of the backup

SET @BackupDate = REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR,GETDATE(),120),'-',''),':',''),' ','_') 
SET @BackupFolder_user = 'Z:\Azure\KroniAG\UserDBs\DATA\'
SET @Baksql = ''
SET @Baksql_ver = ''
SET @Recovery_Model=''



/*
BACKUP USER DATABASES 
*/

-- Declaring cursor
SET @Baksql		= ''
SET @BackupFile = ''


		DECLARE c_bakup CURSOR FAST_FORWARD READ_ONLY FOR

				SELECT NAME , RECOVERY_MODEL_DESC FROM SYS.DATABASES
				WHERE state_desc = 'ONLINE' -- Consider databases which are online
				--AND database_id > 4 -- Exluding system databases
				--AND [NAME] not like 'ReportServer%'
		-- Opening and fetching next values from sursor
		OPEN c_bakup
		FETCH NEXT FROM c_bakup INTO @BackupFile,@Recovery_Model
			WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @BAK_PATH = @BackupFolder_user + @BackupFile
					-- Creating dynamic script for every databases backup
					SET @Baksql = 'BACKUP DATABASE ['+@BackupFile+'] 
					 TO DISK = '''+@BAK_PATH+'_Full_'+@BackupDate+'_01'+'.bak''
					 WITH copy_only,format,  COMPRESSION, NOREWIND, NOUNLOAD, STATS = 10;'
					EXEC(@Baksql)
					set @Baksql =''
					IF @Recovery_Model = 'FULL'
       			    BEGIN
						-- Backup do Log  porque é Full
						SET @Baksql = 'BACKUP LOG ['+@BackupFile+'] 
						TO DISK = '''+@BAK_PATH+'_Log_'+@BackupDate+'_01'+'.trn'' 
						WITH NOFORMAT, NOINIT,  SKIP, NOREWIND, NOUNLOAD,  STATS = 10;'
						EXEC(@Baksql)
					END

				FETCH NEXT FROM c_bakup INTO @BackupFile,@Recovery_Model

			END
			CLOSE c_bakup
			DEALLOCATE c_bakup

		END

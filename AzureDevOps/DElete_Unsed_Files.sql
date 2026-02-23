EXEC prc_CleanupDeletedFileContent 1
EXEC prc_DeleteUnusedFiles 1, 365, 100
    --@partitionId            INT,
    --@retentionPeriodInDays  INT = -1, -- after how many days do we delete the content
    --@chunkSize              INT = 100, -- how many files at a time
    --@reuseFileIdSecondaryRange BIT = 0


SELECT name, schema_name(schema_id) AS SchemaName
FROM sys.procedures
WHERE name LIKE 'prc_Cleanup%';

SELECT TOP (1000) [EVENT_TYPE]
      ,[POST_TIME]
      ,[LOGIN_NAME]
      ,[USERNAME]
      ,[DATABASE_NAME]
      ,[SCHEMA_NAME]
      ,[OBJECTNAME]
      ,[OBJECT_TYPE]
      ,[SQL_TEXT]
      ,[SERVER_NAME]
      ,[HOST_NAME]
  FROM [IDH].[dbo].[SQL_Change_LOG]
  ORDER BY post_time




  
 DECLARE @Deleted_Rows INT;
 SET @Deleted_Rows = 1;


 WHILE (@Deleted_Rows > 0)
   BEGIN
    BEGIN transaction
    -- Delete some small number of rows at a time
	    
    DELETE TOP (100000)  FROM SQL_Change_LOG  
    WHERE post_time < '2024-12-01' ;
    SET @Deleted_Rows = @@ROWCOUNT;
	COMMIT TRANSACTION
	PRINT @Deleted_Rows
    waitfor DELAY '00:00:00:100'
 END
 


USE interfacesdah
GO

DELETE FROM dbo.COF_U_BaseRisco 
WHERE DtProcessamento < '2024-07-01'






 DECLARE @Deleted_Rows INT;
 SET @Deleted_Rows = 1;


 WHILE (@Deleted_Rows > 0)
   BEGIN
    BEGIN transaction
	    
    DELETE TOP (100000) FROM dbo.COF_U_BaseRisco 
    WHERE DtProcessamento < '2024-07-01'
    
	SET @Deleted_Rows = @@ROWCOUNT;
	COMMIT TRANSACTION
	PRINT @Deleted_Rows
    waitfor DELAY '00:00:00:50'

 END
 
 
 -------------------------------
 --------------------
 
 
 DELETE FROM dbo.BCK_U_BaseRisco 
WHERE DtProcessamento < '2024-07-01'


 DECLARE @Deleted_Rows INT;
 SET @Deleted_Rows = 1;


 WHILE (@Deleted_Rows > 0)
   BEGIN
    BEGIN transaction
	    
    DELETE TOP (100000) FROM dbo.BCK_U_BaseRisco 
    WHERE DtProcessamento < '2024-07-01'
    
	SET @Deleted_Rows = @@ROWCOUNT;
	COMMIT TRANSACTION
	PRINT @Deleted_Rows
    waitfor DELAY '00:00:00:50'

 END
 
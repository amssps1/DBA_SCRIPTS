
 DECLARE @Deleted_Rows INT;
 SET @Deleted_Rows = 1;


 WHILE (@Deleted_Rows > 0)
    
   BEGIN
     begin transaction;
    -- Delete some small number of rows at a time
      DELETE TOP (50000)  COF_Erros_APP 
      WHERE CreatedDate < '2024-06-01'
	
   SET @Deleted_Rows = @@ROWCOUNT;
    commit transaction;
 END
-- Register all database assemblies as trusted
declare @name nvarchar(4000),
@content varbinary(max);

DECLARE appCursor CURSOR FAST_FORWARD FOR
    SELECT [name], content
    FROM   IDH.sys.assembly_files
 
OPEN appCursor
FETCH NEXT FROM appCursor INTO @name, @content
 
WHILE @@FETCH_STATUS = 0
BEGIN
   
   DECLARE @hash varbinary(64) = HASHBYTES('SHA2_512', @content);

    EXEC sys.sp_add_trusted_assembly @hash, @name;

   FETCH NEXT FROM appCursor INTO @name, @content
END
CLOSE appCursor
DEALLOCATE appCursor
GO
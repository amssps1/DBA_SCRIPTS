--- ADD
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\amaromg', @useself = N'False', @rmtuser = N'xx', @rmtpassword = N'xx'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\borgesfr', @useself = N'False', @rmtuser = N'xx', @rmtpassword = N'xx'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\castrora', @useself = N'False', @rmtuser = N'xx', @rmtpassword = N'xx'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\duartebe', @useself = N'False', @rmtuser = N'xx', @rmtpassword = N'xx'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\eduardsa', @useself = N'False', @rmtuser = N'xx', @rmtpassword = N'xx'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\goncalrc', @useself = N'False', @rmtuser = N'xx', @rmtpassword = N'xx'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\luzpe', @useself = N'False', @rmtuser = N'xx', @rmtpassword = N'xx'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\mendesjr', @useself = N'False', @rmtuser = N'xx', @rmtpassword = N'xx'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\moraisda', @useself = N'False', @rmtuser = N'xx', @rmtpassword = N'xx'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\rodrigpa', @useself = N'False', @rmtuser = N'xx', @rmtpassword = N'xx'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\rolhoma', @useself = N'False', @rmtuser = N'xx', @rmtpassword = N'xx'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\silvabu', @useself = N'False', @rmtuser = N'xx', @rmtpassword = N'xx'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\silvaru', @useself = N'False', @rmtuser = N'xx', @rmtpassword = N'xx'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\sintraan', @useself = N'False', @rmtuser = N'xx', @rmtpassword = N'xx'
go 


-- Remove


EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\amaromg'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\borgesfr'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\castrora'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\duartebe'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\eduardsa'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\goncalrc'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\luzpe' 
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\mendesjr'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\moraisda'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\rodrigpa'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\rolhoma'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\silvabu'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\silvaru'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'PRIAPO', @locallogin = N'cdm\sintraan'
go 


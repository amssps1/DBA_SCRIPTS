EXEC sp_changedbowner 'sa'
GO
--USE teste_CLR;
--GO
--drop assembly CLRAcessoWS;
--go

--USE teste_CLR;
--GO
--CREATE ASSEMBLY ClrDummy FROM 'F:\CLR\clr\ClrDummy.dll' WITH PERMISSION_SET = SAFE;
--GO

USE master;
GO
CREATE ASYMMETRIC KEY ClrDummy_Key FROM EXECUTABLE FILE = 'F:\CLR\clr\ClrDummy.dll';
GO

USE master;
GO
CREATE LOGIN CLRAcessoWSLogin1 FROM ASYMMETRIC KEY ClrDummy_Key;
GO

USE master;
GO
GRANT UNSAFE ASSEMBLY TO CLRAcessoWSLogin1;
GO

USE teste_CLR;
GO
CREATE USER CLRAcessoWSLogin1 FOR LOGIN CLRAcessoWSLogin1;
GO

CREATE ASSEMBLY ClrDummy FROM 'F:\CLR\clr\ClrDummy.dll' WITH PERMISSION_SET = SAFE;
GO
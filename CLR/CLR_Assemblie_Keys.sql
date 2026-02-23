EXEC sp_changedbowner 'sa'
GO
USE teste;
GO


--USE teste;
--GO
--CREATE ASSEMBLY CLRAcessoWS_1 FROM '\\nornas\automatismosdah$\clr\CLRAcessoWS_1.dll' WITH PERMISSION_SET = SAFE;
--GO

USE master;
GO
CREATE ASYMMETRIC KEY CLRAcessoWS_Key FROM EXECUTABLE FILE = 'c:\CLRAcessoWS_1.dll';
GO

USE master;
GO
CREATE LOGIN CLRAcessoWSLogin FROM ASYMMETRIC KEY CLRAcessoWS_Key;
GO

USE master;
GO
GRANT UNSAFE ASSEMBLY TO CLRAcessoWSLogin;
GO

USE teste;
GO
CREATE USER CLRAcessoWSLogin FOR LOGIN CLRAcessoWSLogin;
GO

CREATE ASSEMBLY CLRAcessoWS_1 FROM 'c:\CLRAcessoWS_1.dll' WITH PERMISSION_SET = SAFE;
GO
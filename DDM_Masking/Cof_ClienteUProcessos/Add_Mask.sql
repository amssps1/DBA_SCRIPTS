
drop index DBA_COF_ClienteUProcesso_NumCont_iactivo on COF_ClienteUProcesso;

ALTER TABLE COF_ClienteUProcesso drop column [NIF] ;

ALTER TABLE COF_ClienteUProcesso  ALTER COLUMN [NumContribuinte] 
ADD MASKED WITH (FUNCTION = 'partial(1, "XXXXXXX", 0)');  

ALTER TABLE COF_ClienteUProcesso ADD  [NIF] AS (CONVERT([numeric],[NumContribuinte])) PERSISTED;




CREATE NONCLUSTERED INDEX [DBA_COF_ClienteUProcesso_NumCont_iactivo] ON [dbo].[COF_ClienteUProcesso]
(
	[iAtivo] ASC,	[NIF] ASC
)
INCLUDE([IDProcesso],[TipoInterveniente],[IDCliente]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


---Para testarem se funciona
/*
CREATE USER DDMTeste WITHOUT LOGIN;  
GRANT SELECT ON COF_ClienteUProcesso TO DDMTeste;  


 
USE IDH 
GO
EXECUTE AS USER = 'DDMTeste';  
SELECT NumContribuinte, NIF from COF_ClienteUProcesso where NumContribuinte ='102135738';  
REVERT;

drop user DDMTeste;
*/
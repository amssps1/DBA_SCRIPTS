



-- remover ddm
USE IDH
go

drop view vw_COF_ProcessoDadosBancarios_Cliente_Morada;
go
ALTER TABLE COF_Cliente  
ALTER COLUMN [Nome] ADD MASKED WITH (FUNCTION = 'partial(1, "XXXXX", 0)');  

ALTER TABLE COF_Cliente  
ALTER COLUMN [PrimeiroNome] ADD MASKED WITH (FUNCTION = 'partial(1, "XXXXX", 0)');  

ALTER TABLE COF_Cliente  
ALTER COLUMN [UltimoNome]  ADD MASKED WITH (FUNCTION = 'partial(1, "XXXXX", 0)');

ALTER TABLE COF_Cliente  
ALTER COLUMN [NumContribuinte] ADD MASKED WITH (FUNCTION = 'partial(1, "XXXXX", 0)');
go


CREATE VIEW [dbo].[vw_COF_ProcessoDadosBancarios_Cliente_Morada]
WITH SCHEMABINDING
AS

	WITH CTE AS (
		SELECT DISTINCT cp.IDProcesso
			,CP.NumProspect
			,cp.TipoInterveniente
			,c.IdCliente
			,c.Nome
			,cm.Morada
			,cm.CodPostal1
			,cm.CodPostal2
			,cm.Localidade
			,CP.Ordem
			,pdb.RefADC
			,CONCAT(pdb.PrefixoIBAN, pdb.NIB) IBAN
			,b.Banco
			,pdb.CodBanco
		FROM dbo.COF_ProcessoDadosBancarios pdb
			INNER JOIN dbo.COF_ClienteUProcesso CP ON cp.IDCliente = pdb.IDCliente 
				AND cp.IDProcesso = pdb.IDProcesso
			INNER JOIN dbo.COF_Cliente C ON c.IDCliente = pdb.IDCliente
			INNER JOIN dbo.COF_ClienteMorada CM ON cm.IDCliente = c.IDCliente 
				AND CM.Active = 1
			LEFT JOIN dbo.COF_Banco b ON b.CodBanco = pdb.CodBanco
		WHERE NULLIF(pdb.NIB, '') IS NOT NULL
	)
	SELECT t2.NumIBAN + 1 AS NumIBAN
		  ,t.Ordem
		  ,t.IDProcesso
		  ,t.NumProspect
		  ,t.TipoInterveniente
		  ,t.IdCliente
		  ,t.Nome
		  ,t.Morada
		  ,t.CodPostal1
		  ,t.CodPostal2
		  ,t.Localidade
		  ,t.RefADC
		  ,t.IBAN
		  ,t.Banco
		  ,t.CodBanco
	FROM CTE t
		CROSS APPLY ( SELECT COUNT(DISTINCT ISNULL(i.RefADC, 0)) NumIBAN
					  FROM CTE AS i 
					  WHERE i.IDProcesso = t.IDProcesso 
					  AND ISNULL(i.RefADC, 0) < ISNULL(t.RefADC, 0) ) AS t2


GO



--
ALTER TABLE COF_ContactoTelefonico  
ALTER COLUMN [Numero]  ADD MASKED WITH (FUNCTION = 'default()');

------
-- Pedido Ferreira via Reporte 570035
ALTER TABLE COF_BancoPortugalCRC 
ALTER COLUMN [Nome] ADD MASKED WITH (FUNCTION = 'partial(1, "XXXXXXXXXXX", 0)'); 



--COF_ClienteUProcesso (script que me enviasta já com hot fixes)

drop index DBA_COF_ClienteUProcesso_NumCont_iactivo on COF_ClienteUProcesso;
ALTER TABLE COF_ClienteUProcesso drop column [NIF] ;

ALTER TABLE COF_ClienteUProcesso  ALTER COLUMN [NumContribuinte] ADD MASKED WITH (FUNCTION = 'partial(1, "XXXXXXX", 0)');  
ALTER TABLE COF_ClienteUProcesso ADD  [NIF] AS (CONVERT([numeric],[NumContribuinte])) PERSISTED;

CREATE NONCLUSTERED INDEX [DBA_COF_ClienteUProcesso_NumCont_iactivo] ON [dbo].[COF_ClienteUProcesso]
(
       [iAtivo] ASC, [NIF] ASC
)
INCLUDE([IDProcesso],[TipoInterveniente],[IDCliente]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO



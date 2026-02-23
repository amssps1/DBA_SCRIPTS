USE [IDH]
GO

SET ANSI_PADDING ON
GO
drop index [DBA_NCIX_COF_CLi_UPROCESSO_Tit_Tip_iActivo] ON [dbo].[COF_ClienteUProcesso]
go

/****** Object:  Index [DBA_NCIX_COF_CLi_UPROCESSO_Tit_Tip_iActivo]    Script Date: 15/02/2024 09:28:22 ******/
CREATE NONCLUSTERED INDEX [DBA_NCIX_COF_CLi_UPROCESSO_Tit_Tip_iActivo] ON [dbo].[COF_ClienteUProcesso]
(
	[Titular] ASC,
	[TipoInterveniente] ASC,
	[iAtivo] ASC
)
INCLUDE([IDCliente],[NumDossier],[TipoCliente],[IDProcesso],[NumContribuinte]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 95) ON [Secondary]
GO



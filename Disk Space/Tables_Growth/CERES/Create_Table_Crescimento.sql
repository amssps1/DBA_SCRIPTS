USE [dba_db]
GO

/****** Object:  Table [dbo].[Tabela_Crescimento_Rows]    Script Date: 21/07/2025 14:20:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Tabela_Crescimento_Rows](
	[CaptureDate] [DATETIME] NOT NULL,
	[DatabaseName] [sysname] NOT NULL,
	[SchemaName] [sysname] NOT NULL,
	[TableName] [sysname] NOT NULL,
	[RowCount] [BIGINT] NOT NULL,
	[DeltaRows] [BIGINT] NULL,
	[UsedKB] [BIGINT] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tabela_Crescimento_Rows] ADD  DEFAULT (GETDATE()) FOR [CaptureDate]
GO



CREATE TABLE [dbo].[TableSizeGrowth](
[id] [int] IDENTITY(1,1) NOT NULL,
[database_name] [nvarchar](256) NULL,
[table_schema] [nvarchar](256) NULL,
[table_name] [nvarchar](256) NULL,
[table_rows] [int] NULL,
[reserved_space] [int] NULL,
[data_space] [int] NULL,
[date] [datetime] NULL
) ON [PRIMARY]
  

ALTER TABLE [dbo].[TableSizeGrowth] ADD CONSTRAINT [DF_TableSizeGrowth_date]  
DEFAULT (dateadd(day,(0),datediff(day,(0),getdate()))) FOR [date]
GO


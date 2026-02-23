USE [db_cofidis_dah_interface_aux]
GO

--Preparação para a criação de Columnstore Indexs
DECLARE @count		INT = 0;
DECLARE @rowCount	INT = 0;
DECLARE @sqlCommand VARCHAR(MAX);

DECLARE @tblInput TABLE (
	[Nome] VARCHAR(50)
);

DECLARE @tblOutput TABLE (
	[ID]	INT IDENTITY(1,1),
	[Query]	VARCHAR(MAX)
);

--Inserir as tabelas alvo
INSERT INTO @tblInput
VALUES ('SaldoDia');

INSERT INTO @tblOutput (Query)
SELECT IIF(I.IS_PRIMARY_KEY = 1 OR I.IS_UNIQUE_CONSTRAINT = 1, 
		CONCAT('ALTER TABLE [', S.Name, '].[', T.Name,'] DROP CONSTRAINT [', I.Name,'];'),
		CONCAT('DROP INDEX [', I.Name,'] ON [', S.Name, '].[', T.Name,'];'))
FROM SYS.INDEXES I
INNER JOIN SYS.TABLES T
	ON (T.OBJECT_ID = I.OBJECT_ID)
INNER JOIN SYS.SCHEMAS S
	ON (T.SCHEMA_ID = S.SCHEMA_ID)
INNER JOIN @tblInput C
	ON (C.Nome = T.Name)
WHERE I.Name IS NOT NULL
  AND I.Type IN (1, 2);

SET @rowCount = @@ROWCOUNT;

WHILE (@count < @rowCount)
BEGIN
	SET @count += 1;

	SET @sqlCommand = (
		SELECT Query
		FROM @TblOutput
		WHERE ID = @count);

	--PRINT @sqlCommand
	EXEC (@sqlCommand);
END

CREATE CLUSTERED COLUMNSTORE INDEX [CCIX_SaldoDia] ON [dbo].[SaldoDia] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, DATA_COMPRESSION = COLUMNSTORE);
GO

UPDATE STATISTICS [dbo].[SaldoDia];
GO

sp_spaceused saldodia

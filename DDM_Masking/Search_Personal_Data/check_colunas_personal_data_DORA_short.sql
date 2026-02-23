/*-------------------------------------------------------------------------------------- 
-- Title: Using sys.columns to discover columns that hold personal data - GDPR
-- Author: Fran Lens - Aleson ITC (https://aleson-itc.com)
-- Date: 2018-06-22
-- Description: This script will help us discover columns that may contain personal data, by default
                look for a few candidate words in Spanish and English, but you can add the ones you want.
                You can put the words in uppercase or lowercase or with or without accents, it will find them.
--------------------------------------------------------------------------------------*/

-- Variable declarations
DECLARE @DatabaseName nvarchar(100)
		, @Word nvarchar(50)
		, @SQL nvarchar(max)

-- Delete the #Words table if it exists
IF OBJECT_ID('tempdb.dbo.#Words', 'U') IS NOT NULL
DROP TABLE #Words;

-- Delete the table #DiscoverGDPR if it exists
IF OBJECT_ID('tempdb.dbo.#DiscoverGDPR', 'U') IS NOT NULL
DROP TABLE #DiscoverGDPR;

-- Creation of table #Words
CREATE TABLE #Words (word nvarchar(50))

-- Creation of table #DiscoverGDPR
CREATE TABLE #DiscoverGDPR (DatabaseName nvarchar(100), SchemaName nvarchar(100), TableName nvarchar(100), ColumnName nvarchar(100))

-- Insert words to search in the table #Words
INSERT INTO #Words VALUES
-- Portugues e ingles


--('Banco')
--,('Conta')
--,('Matricula')
--,('NomeCliente')
--,('NumContribuinteA')
--,('NumContribuinteB')
--,('NIF')
--,('Matricula')
--,('Chassi (NumChassi)')
--,('Matricula')
--,('Localidade')
--,('NomeA')
--,('Nome')
--,('NomeB')

('NIF')
,('Contribuinte')
,('nipc')

--,('nifNipc')
--,('nipc')
--,('T2NIF')
--,('NifComprador')
--,('Nome')
--,('PrimeiroNome')
--,('UltimoNome')
--,('Email')
--,('IBAN')
--,('Morada')
--,('NIB')
--,('NIF')
--,('PrimeiroNome')
--,('Telemovel')

--,('Matricula')
--,('NomeCliente')

--,('Produto')
--,('Email')
--,('Nome')
--,('NumTelemovel')
--,('Mensagem')
--,('NumTelefone')
--,('CodPostal1')
--,('CodPostal2')
--,('Email')
--,('Morada')
--,('Telefone_Casa')
--,('Telemovel')
--,('Telemovel_2')
--,('NomeT2')
--,('Bank')
--,('Card')
--,('Account')
--,('Number')
--,('IP')

-- We create a cursor with the Databases in which we want to find the information
DECLARE db_cursor CURSOR
FOR 

	SELECT	name 
	FROM	master.sys.databases
	WHERE name IN ('IDH');

-- We start cursor db_cursor
OPEN db_cursor

-- Advance db_cursor
FETCH NEXT FROM db_cursor INTO @DatabaseName;

-- Loop db_cursor
WHILE @@FETCH_STATUS = 0
BEGIN

-- We create a cursor that travels the table #Words
DECLARE Word_Cursor CURSOR FOR 
SELECT * FROM #Words

-- We start cursor Word_Cursor
OPEN Word_Cursor 

-- Advance Word_Cursor
FETCH NEXT FROM Word_Cursor INTO @Word

-- Loop Word_Cursor
WHILE @@FETCH_STATUS = 0
BEGIN 

	-- Creating the query
	SET @SQL =	'USE ' + @DatabaseName + ';' +

				'INSERT INTO #DiscoverGDPR ' +
				'SELECT	''' + @DatabaseName + ''' AS [database], ' +
				'		SCHEMA_NAME(schema_id) AS [schema],  ' +
				'		t.name AS table_name, c.name AS column_name ' + 
				'FROM	sys.tables AS t ' + 
				'INNER JOIN sys.columns c ON t.OBJECT_ID = c.OBJECT_ID ' + 
				'WHERE	c.name LIKE ''%'+ @Word +'%'' COLLATE SQL_Latin1_General_CP1_CI_AI' 
	
	-- Executing query
	EXEC sp_executesql @SQL

-- Advance Word_Cursor
FETCH NEXT FROM Word_Cursor INTO @Word

END

-- Close and delete cursor Word_Cursor
CLOSE Word_Cursor 
DEALLOCATE Word_Cursor 

-- Advance db_cursor
FETCH NEXT FROM db_cursor INTO @DatabaseName;

END

-- Close and delete cursor db_cursor
CLOSE db_cursor;
DEALLOCATE db_cursor;

-- Showing the data
SELECT *
FROM #DiscoverGDPR
ORDER BY DatabaseName, SchemaName, TableName, ColumnName


---------------------------------   
;WITH CTE(DatabaseName, 
    SchemaName, 
    TableName, 
	ColumnName,
    duplicatecount)
AS (SELECT DatabaseName, 
           SchemaName, 
           TableName, 
		   ColumnName,
           ROW_NUMBER() OVER(PARTITION BY SchemaName,TableName, 
                                          ColumnName
           ORDER BY DatabaseName) AS DuplicateCount
    FROM #DiscoverGDPR)
SELECT *
FROM CTE where duplicatecount <2;
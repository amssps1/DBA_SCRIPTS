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
-- Portugues
('Nome')
,('Apelido')
,('Telefone')
,('Tel') 
,('Tfno')
,('Telemóvel')
,('Telemovel')
,('Telemovel_2')
,('Telefone_Casa')
,('Mensagem')
,('Morada')
,('Freguesia')
,('Cidade')
,('Pais')
,('Postal') 
,('CP')
,('Nacionalidade') 
,('CC')
,('NIF')
,('SS')
,('Passaporte')
,('Identifi')
,('Mail') 
,('Correio') 
,('Foto') 
,('Banco')
,('Cartão')
,('Conta')
,('Numero') 
,('IBAN')
,('Filho')
,('Filha')
,('Esposa')
,('PrimeiroNome')
,('UltimoNome')
,('NumContribuinte')
,('DataNascimento')
,('NumDocIdentificacao')
,('Email')
,('NomeCartao')
,('ContatoMovel')
,('Contacto3DSecure')
,('DtNascimento')
,('Numero')
,('Chassi')
,('Matricula')
,('Chassis')
,('DataNacimento')
,('NumDocumento')
,('CheckDigit')
,('TelefoneContacto')
,('T2Nome')
,('T2DataNacimento')
,('T2NIF')
,('T2NumDocumento')
,('T2CheckDigit')
,('T2TelefoneContacto')
,('T2Email')
,('TelefoneTrabalhoT1')
,('TelefoneOutroContactoT1')
,('TelefoneTrabalhoT2')
,('TelefoneOutroContactoT2')
,('NumMatricula')
,('NumChassis')
,('PrefixoIBAN')
,('NIB')
,('RefADC')
,('NifComprador')
,('IbanMSO')
,('email')
,('texto')
,('NIBActual')
,('NIBAnterior')
,('IBANActual')
,('IBANAnterior')
,('NomeBeneficiario')
,('IBANBeneficiario')
,('IBANAntBeneficiario')
,('NomeA')
,('NomeB')
,('DtNascimentoA')
,('DtNascimentoB')
,('NumContribuinteA')
,('NumContribuinteB')
,('NumBI')
,('NumTelefone')
,('NumTelefone1')
,('NumTelefone2')
,('NumTelefoneEmprego')
,('NumConta')
,('XMLData')
,('NomeSocio')
,('NomeLocatario')
,('CartaoDoCidadao')
,('NomeT2')
,('NomeT3')
,('TelfServico')
,('Nib')
,('Parceiro')
,('NomeCliente')
,('Info')
,('Mutuario1NIF')
,('Mutuario2NIF')
,('NumContribuinte1')
,('NumContribuinte2')
,('NumTelemovel')
,('DetailSet')
,('Nbalcao')
,('Nconta')
,('Valor')
,('NDocIdentificacao')
,('Npassaport')
,('NSegSocial')
,('NumSerie')
,('Url')
,('IDProcessoDocImagem')
,('OcrValor')
,('ValorComparado')
,('dtNasc')
,('nifNipc')
,('RestoNome')
,('correctint_nome')
,('actint_nome')
,('actint_dtnasc')
,('correctint_nifnipc')
,('actint_nifnipc')
,('conta_actconta_nifnipc')
,('conta_num')
,('RestNome')
,('UltNome')
,('partdtNasc')
,('DtNasc')
,('NumContribuinteCliente')
,('numero')
,('TlfServico')
,('NomeParceiro')
,('CLIENTEMAIL')
,('CLIENTPHONE')
,('GENDER')
,('NAME')
,('BIRTHDATE')
,('CCNUMBER')
,('CCVALIDATIONDATE')
,('VATNUMBER')
,('SSNUMBER')
,('CCNUMBER_TEXT')
,('CLIENTNAME')
,('DOCUMENTNUMBER')
,('CHECKDIGITS')
,('EMAIL')
,('PHONE1')
,('PHONE2')
,('PHONEEMPLOYER')
,('SEGSOCIALNUMBER')
,('PLATE')
,('CHASSI')
,('SERIE')
,('FIRSTHOLDERNAME')
,('FIRSTHOLDERSHORTNAME')
,('SECONDHOLDERNAME')
,('SECONDHOLDERSHORTNAME')
,('firstname')
,('lastname')
,('NOME')
,('Memo')
,('NumAndar')
,('Localidade')
,('CodPostal1')
,('CodPostal2')
,('LocalidadePostal')
,('NumPorta')
,('Referencia')
,('IdReferenciaComunicacao')
,('IDArquivo')
,('ReuAceitante')
,('NIPC')
,('Codigo Postal')
,('NumeroContribuinte')
,('BankReaderResponse')

-- We create a cursor with the Databases in which we want to find the information
DECLARE db_cursor CURSOR
FOR 

	SELECT	name 
	FROM	master.sys.databases
	WHERE name IN ('ARMADA')
--	and name IN ('IDH')
--	and  is_read_only = 0;

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
--				'WHERE	c.name LIKE ''%'+ @Word +'%'' COLLATE Latin1_General_CI_AS '	
				'WHERE	c.name LIKE '''+ @Word +''' COLLATE Latin1_General_CI_AS '	

		
-- --COLLATE SQL_Latin1_General_CP1_CI_AI	
	-- Executing query
	--print @SQL
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
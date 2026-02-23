
SET IDENTITY_INSERT COFIDIS_Organizacao ON
INSERT INTO COFIDIS_Organizacao([ID_Org],[Nome],[ParentId],[TipoOrganizacaoId],[ResponsavelID],[CodS4],[Activo],[CreatedDate],[CreatedByUser],[UpdatedDate],[UpdatedByUser],[ManagerId],[IdLoja])VALUES('299','Serviço de Gestão de Fraude Operacional','298','2','5384','','1',TRY_CONVERT( DATETIME,'mar  4 2024 10:10AM' ),'2312',TRY_CONVERT( DATETIME,'abr 10 2024 11:54AM' ),'2312' ,'2607',NULL)


SET IDENTITY_INSERT COFIDIS_Organizacao OFF



select * from Dotnetnuke..COFIDIS_Organizacao
where ID_Org = 299



DECLARE 
     @includePK BIT = 1,
     @table VARCHAR(MAX) = 'COFIDIS_Organizacao',
--     @dataFilter VARCHAR(MAX) = 'WHERE date = ''2020-03-10'' '
     @dataFilter VARCHAR(MAX) = 'where ID_Org = 298 '

DECLARE 
     @columnNames VARCHAR(MAX) = '',
     @getDataColumnScript VARCHAR(MAX),
     @queryToGenerateScript VARCHAR(MAX)

-- Get a list of all colmuns
SELECT @columnNames = STUFF
(
    (
     SELECT ',['+ NAME +']' FROM sys.all_columns 
     WHERE OBJECT_ID = OBJECT_ID(@table)
     AND (is_identity != 1 OR @includePK = 1)
     FOR XML PATH('')
    ),
     1,
     1,
     ''
)

-- Create a the column part of the select using the column names
SELECT @getDataColumnScript = STUFF
(
    (
     SELECT ' ISNULL(QUOTENAME(' + NAME + ',' + QUOTENAME('''','''''') + '),' + '''NULL''' + ')+'',''' + '+' FROM sys.all_columns 
     WHERE OBJECT_ID = OBJECT_ID(@table)
     AND (is_identity != 1 OR @includePK = 1)
     FOR XML PATH('')
    ),
     1,
     1,
     ''
)

SELECT @queryToGenerateScript = 'SELECT ''' +
     'INSERT INTO ' + @table + '(' + @columnNames + ')' + 
     'VALUES(''' + '+' + SUBSTRING(@getDataColumnScript, 1, LEN(@getDataColumnScript) -5) + '+' + ''')''' + ' OutputScript ' +
     'FROM ' + @table + ' ' + @dataFilter

EXECUTE (@queryToGenerateScript)

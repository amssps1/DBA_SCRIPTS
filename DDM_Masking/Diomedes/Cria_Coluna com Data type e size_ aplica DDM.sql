/*
Script para data masking e criar o size e o tipo de dados de cada coluna/tabela
*/


--truncate table TargetTable
-- Verify the data in the target table
SELECT * FROM TargetTable;

UPDATE TargetTable
SET [Data Type] = c.DATA_TYPE,
    [Size] = CASE 
        WHEN c.DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar') THEN c.CHARACTER_MAXIMUM_LENGTH
        WHEN c.DATA_TYPE IN ('decimal', 'numeric') THEN c.NUMERIC_PRECISION
        ELSE NULL
    END
FROM TargetTable st
JOIN INFORMATION_SCHEMA.COLUMNS c
    ON c.TABLE_NAME = st.TableName
    AND c.COLUMN_NAME = st.ColumnName
WHERE c.TABLE_SCHEMA = 'dbo'; -- Adjust if the schema is different


-----

-- passo 2 
UPDATE TargetTable
SET [Data Type] = 
    CASE 
        WHEN [Size] IS NOT NULL THEN CONCAT([Data Type], '(', [Size], ')')
        ELSE [Data Type]
    END;

--
-- Passo 3
-- Actualizar data types com Varchar(-1)
UPDATE TargetTable
SET [Data Type] = 
    CASE 
        WHEN [Size] = '-1' THEN 'VARCHAR(4000)'
        ELSE [Data Type]
    END;

--






UPDATE TargetTable
SET ddm_command = 
    CASE
        -- Case 1: Data Type contains "varchar"
        WHEN [Data Type] LIKE '%varchar%' OR [Data Type] LIKE 'char%' OR [Data Type] LIKE 'DATETIME' THEN 
            CONCAT(
                'ALTER TABLE [', TableName, '] ',
                'ALTER COLUMN [', ColumnName, '] ',
                'ADD MASKED WITH (FUNCTION = ''default()'');'
            )
        
        -- Case 2: Data Type contains "numeric", "int", or "decimal"
        WHEN [Data Type] LIKE '%numeric%' 
             OR [Data Type] LIKE '%int%' 
             OR [Data Type] LIKE '%decimal%' THEN 
            CONCAT(
                'ALTER TABLE [', TableName, '] ',
                'ALTER COLUMN [', ColumnName, '] ',
                'ADD MASKED WITH (FUNCTION = ''partial(1, "XXXXX", 0)'');'
            )
		WHEN [ColumnName] LIKE 'NumContribuinte%' THEN  CONCAT(
                'ALTER TABLE [', TableName, '] ',
                'ALTER COLUMN [', ColumnName, '] ',
                'ADD MASKED WITH (FUNCTION = ''default()'');'
		)
        -- Default: NULL if no match
        ELSE NULL
    END;



UPDATE TargetTable
SET ddm_command = CONCAT(
                'ALTER TABLE [', TableName, '] ',
                'ALTER COLUMN [', ColumnName, '] ',
                'ADD MASKED WITH (FUNCTION = ''default()'');'
				)

WHERE [ColumnName] LIKE '%NumContribuinte%' OR [ColumnName] LIKE 'NIF%' OR [ColumnName] LIKE 'Telemovel%' OR [ColumnName] LIKE '%Telefone%'
OR [ColumnName] LIKE 'NIP%'
OR [ColumnName] LIKE 'Conta%'
OR [ColumnName] LIKE 'CodPostal%'
OR [ColumnName] LIKE 'EntityFiscalNumber%'
OR [ColumnName] LIKE 'ChkDigit%'
OR [ColumnName] LIKE 'IdConta%'
OR [ColumnName] LIKE 'PortugueseTaxId%'
OR [ColumnName] LIKE 'iFamiliarPEP%'
OR [ColumnName] LIKE 'iPEP%'

--    CASE


--	         WHEN [ColumnName] LIKE 'NumContribuinte%' THEN  CONCAT(
--                'ALTER TABLE [', TableName, '] ',
--                'ALTER COLUMN [', ColumnName, '] ',
--                'ADD MASKED WITH (FUNCTION = ''default()'');'
--		)
--		        -- Default: NULL if no match
--        ELSE NULL
--    END;
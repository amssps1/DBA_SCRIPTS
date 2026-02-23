

/* Extended Properties para Tabelas*/

SELECT
   SCHEMA_NAME(tbl.schema_id) AS SchemaName,
   tbl.name AS TableName, 
   p.name AS ExtendedPropertyName,
   CAST(p.value AS sql_variant) AS ExtendedPropertyValue
FROM
   sys.tables AS tbl
   INNER JOIN sys.extended_properties AS p ON p.major_id=tbl.object_id AND p.minor_id=0 AND p.class=1

   ORDER BY TableName


   /* Extended Properties para Colunas*/

   SELECT
   SCHEMA_NAME(tbl.schema_id) AS SchemaName,
   tbl.name AS TableName, 
   clmns.name AS ColumnName,
   p.name AS ExtendedPropertyName,
   CAST(p.value AS SQL_VARIANT) AS ExtendedPropertyValue
FROM
   sys.tables AS tbl
   INNER JOIN sys.all_columns AS clmns ON clmns.object_id=tbl.object_id
   INNER JOIN sys.extended_properties AS p ON p.major_id=tbl.object_id AND p.minor_id=clmns.column_id AND p.class=1
 
 
 /* - para ver a classoificação do tipo de dados -*/

 SELECT 
    SCHEMA_NAME(O.schema_id) AS schema_name,
    O.NAME AS table_name,
    C.NAME AS column_name,
    information_type,
	label,
	rank,
	rank_desc
FROM sys.sensitivity_classifications sc
    JOIN sys.objects O
    ON  sc.major_id = O.object_id
	JOIN sys.columns C 
    ON  sc.major_id = C.object_id  AND sc.minor_id = C.column_id
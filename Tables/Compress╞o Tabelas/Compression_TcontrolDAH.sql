-- Verificar o espaço usado antes
sp_estimate_data_compression_savings 
    @schema_name = 'dbo', 
    @object_name = 'TCD_Transaction',
    @index_id = NULL, 
    @partition_number = NULL, 
    @data_compression = 'PAGE'; -- ou 'ROW'




ALTER TABLE TCD_Transaction 
REBUILD PARTITION = ALL 
WITH (DATA_COMPRESSION = PAGE);

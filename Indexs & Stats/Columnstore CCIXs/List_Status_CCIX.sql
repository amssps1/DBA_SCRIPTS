select
    i.name,
    rg.object_id,
    rg.partition_number,
    rg.row_group_id,
    rg.delta_store_hobt_id,
    rg.state_desc,
    rg.total_rows,
    rg.deleted_rows,
    100.0*(ISNULL(rg.deleted_rows,0))/total_rows AS 'Fragmentation',
    rg.created_time,
    rg.closed_time
from sys.dm_db_column_store_row_group_physical_stats rg
inner join sys.indexes i
on rg.object_id = i.object_id
and rg.index_id = i.index_id
order by i.name
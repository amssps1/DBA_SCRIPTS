SELECT
    OBJECT_NAME(p.object_id) AS table_name,
    p.index_id,
    p.rows,
    au.type_desc AS alloc_unit_type,
    au.used_pages,
    fg.name AS fg_name
FROM
    sys.partitions as p
JOIN
    sys.allocation_units AS au on p.hobt_id = au.container_id
JOIN   
    sys.filegroups AS fg on fg.data_space_id = au.data_space_id
WHERE
    p.object_id = OBJECT_ID('ComunicacaoProcessada')
ORDER BY table_name
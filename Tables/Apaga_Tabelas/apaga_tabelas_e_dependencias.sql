/* ====== PARAMETROS ====== */
DECLARE @DbName sysname = N'FM_REPORTING';

/* ====== EXECUCAO ====== */
DECLARE @sql nvarchar(max) = N'USE ' + QUOTENAME(@DbName) + N';
SET NOCOUNT ON;

PRINT ''[INFO] A eliminar todas as tabelas de utilizador da BD '' + DB_NAME() + ''...'';

/* 1) Desligar SYSTEM_VERSIONING nas tabelas temporais e dropar history tables */
DECLARE @cmd nvarchar(max) = N''''; 

;WITH TT AS (
    SELECT 
        Sch     = s.name,
        Tbl     = t.name,
        HistSch = SCHEMA_NAME(ht.schema_id),
        HistTbl = ht.name
    FROM sys.tables AS t
    JOIN sys.schemas AS s ON s.schema_id = t.schema_id
    LEFT JOIN sys.tables  AS ht ON ht.object_id = t.history_table_id
    WHERE t.temporal_type = 2   -- SYSTEM_VERSIONED
      AND t.is_ms_shipped = 0
)
SELECT @cmd = @cmd +
    N''ALTER TABLE '' + QUOTENAME(Sch) + N''.'' + QUOTENAME(Tbl) + N'' SET (SYSTEM_VERSIONING = OFF);'' + CHAR(10) +
    CASE WHEN HistSch IS NOT NULL AND HistTbl IS NOT NULL
         THEN N''DROP TABLE '' + QUOTENAME(HistSch) + N''.'' + QUOTENAME(HistTbl) + N'';'' + CHAR(10)
         ELSE N'''' END
FROM TT;

IF (LEN(@cmd) > 0)
BEGIN
    PRINT ''[INFO] Desligar temporal e dropar history tables...'';
    EXEC sys.sp_executesql @cmd;
END

/* 2) Remover todas as FOREIGN KEYS nas tabelas de utilizador */
SET @cmd = N'''';
;WITH FK AS (
    SELECT 
        ChildSch = s.name,
        ChildTbl = t.name,
        FKName   = fk.name
    FROM sys.foreign_keys AS fk
    JOIN sys.tables       AS t ON t.object_id = fk.parent_object_id
    JOIN sys.schemas      AS s ON s.schema_id = t.schema_id
    WHERE fk.is_ms_shipped = 0
)
SELECT @cmd = @cmd + 
       N''ALTER TABLE '' + QUOTENAME(ChildSch) + N''.'' + QUOTENAME(ChildTbl) +
       N'' DROP CONSTRAINT '' + QUOTENAME(FKName) + N'';'' + CHAR(10)
FROM FK;

IF (LEN(@cmd) > 0)
BEGIN
    PRINT ''[INFO] A remover FOREIGN KEYS...'';
    EXEC sys.sp_executesql @cmd;
END

/* 3) Dropar todas as tabelas de utilizador */
SET @cmd = N'''';
;WITH T AS (
    SELECT Sch = s.name, Tbl = t.name
    FROM sys.tables t
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE t.is_ms_shipped = 0
)
SELECT @cmd = @cmd + 
       N''DROP TABLE '' + QUOTENAME(Sch) + N''.'' + QUOTENAME(Tbl) + N'';'' + CHAR(10)
FROM T
ORDER BY Sch, Tbl;

IF (LEN(@cmd) > 0)
BEGIN
    PRINT ''[INFO] A dropar tabelas...'';
    EXEC sys.sp_executesql @cmd;
END

PRINT ''[OK] Todas as tabelas de utilizador foram eliminadas.'';
';

EXEC sys.sp_executesql @sql;

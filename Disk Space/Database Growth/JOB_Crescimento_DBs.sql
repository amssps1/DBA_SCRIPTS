USE msdb;
GO

DECLARE @job_id UNIQUEIDENTIFIER;

-- cria o job
EXEC sp_add_job
    @job_name = N'DBA_Crescimento BDs',
    @enabled  = 1,
    @description = N'Capta tamanhos (GB) de todas as BDs de utilizador no 1.º dia de cada mês e calcula crescimento mensal.',
    @category_name = N'Database Maintenance',
    @owner_login_name = N'sa',
    @job_id = @job_id OUTPUT;

-- passo: executar a procedure
EXEC sp_add_jobstep
    @job_id = @job_id,
    @step_name = N'Capture Monthly Sizes',
    @subsystem = N'TSQL',
    @database_name = N'master',
    @command = N'EXEC dbo.usp_Snapshot_Tabela_Crescimento_BDs;',
    @retry_attempts = 3,
    @retry_interval = 5;

-- agenda: dia 1 de cada mês às 02:00
EXEC sp_add_schedule
    @schedule_name = N'Monthly Day1 at 02:00',
    @freq_type = 16,                 -- monthly
    @freq_interval = 1,              -- day 1
    @freq_recurrence_factor = 1,     -- every month
    @active_start_time = 020000;     -- 02:00

-- associa agenda ao job
EXEC sp_attach_schedule
    @job_id = @job_id,
    @schedule_name = N'Monthly Day1 at 02:00';

-- servidor-alvo (local)
EXEC sp_add_jobserver
    @job_id = @job_id,
    @server_name = N'(LOCAL)';

--
-- EXEC dbo.DBA_Crescimento BDs;
GO


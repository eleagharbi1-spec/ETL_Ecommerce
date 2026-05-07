-- Script to create SQL Server Agent job to run SSIS package (requires SQL Server Agent running)
-- Adjust @package_path, @job_name and @proxy_name if needed
DECLARE @job_name NVARCHAR(128) = 'Job_Load_Amazon_CSV';
DECLARE @package_path NVARCHAR(512) = N'/SSISDB/YourFolder/YourProject/Load_Amazon_CSV.dtsx'; -- update to your SSISDB path

IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = @job_name)
    EXEC msdb.dbo.sp_delete_job @job_name = @job_name;

EXEC msdb.dbo.sp_add_job @job_name = @job_name, @enabled = 1, @description = N'Job to run Load_Amazon_CSV SSIS package';

-- Add step to run SSIS package from SSISDB (Integration Services Catalog)
EXEC msdb.dbo.sp_add_jobstep
    @job_name = @job_name,
    @step_name = 'Run SSIS Package',
    @subsystem = 'SSIS',
    @command = N'/ISSERVER "" /SERVER "" /PROJECT "" /PACKAGE "' + @package_path + '"',
    @database_name = 'msdb';

-- Schedule can be added here (example daily at 2 AM)
EXEC msdb.dbo.sp_add_schedule
    @schedule_name = N'Schedule_Daily_Load_Amazon',
    @enabled = 1,
    @freq_type = 4, -- daily
    @freq_interval = 1,
    @active_start_time = 20000; -- 02:00:00

EXEC msdb.dbo.sp_attach_schedule @job_name = @job_name, @schedule_name = N'Schedule_Daily_Load_Amazon';

-- Add job to server
EXEC msdb.dbo.sp_add_jobserver @job_name = @job_name;

PRINT 'Created SQL Agent job: ' + @job_name;

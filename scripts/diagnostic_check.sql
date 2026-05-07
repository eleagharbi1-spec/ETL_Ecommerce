-- Diagnostic script to determine ETL run status
-- Run this in SSMS against projetDW

PRINT 'Staging summary';
SELECT MAX(LoadDate) AS LastLoad, COUNT(*) AS RowCount FROM dbo.stg_Amazon;

PRINT 'Fact summary';
SELECT MAX(StartDate) AS LastFactInsert, COUNT(*) AS CurrentRows FROM dbo.fct_Amazon WHERE IsCurrent = 1;

PRINT 'Errors summary';
SELECT COUNT(*) AS ErrorCount FROM dbo.err_Amazon;

PRINT 'Hash checks on staging';
SELECT
    COUNT(*) AS TotalStaging,
    SUM(CASE WHEN BusinessKeyHash IS NULL THEN 1 ELSE 0 END) AS MissingBusinessKeyHash,
    SUM(CASE WHEN RowHash IS NULL THEN 1 ELSE 0 END) AS MissingRowHash
FROM dbo.stg_Amazon;

PRINT 'Recent ETL control entries';
SELECT TOP 20 * FROM dbo.etl_control ORDER BY StartTime DESC;

-- Check SSISDB if available
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('SSISDB.catalog.executions') AND type = 'U')
BEGIN
    PRINT 'Recent SSISDB executions (if SSISDB present)';
    SELECT TOP 20 execution_id, folder_name, project_name, package_name, status, start_time, end_time
    FROM SSISDB.catalog.executions
    ORDER BY start_time DESC;
END

PRINT 'Done.';

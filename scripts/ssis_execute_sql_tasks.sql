-- SQL snippets to insert audit records from SSIS Execute SQL Task
-- Insert start
INSERT INTO dbo.etl_control (SourceFileName, PackageName, StartTime, Status)
VALUES (?, ?, SYSDATETIME(), 'Started');

-- Update end (use BatchID returned from previous insert as parameter)
UPDATE dbo.etl_control
SET EndTime = SYSDATETIME(), RowCount = ?, ErrorCount = ?, Status = ?, Message = ?
WHERE BatchID = ?;

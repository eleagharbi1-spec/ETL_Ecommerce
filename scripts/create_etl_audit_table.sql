-- Create ETL audit/control table
IF OBJECT_ID('dbo.etl_control','U') IS NOT NULL
    DROP TABLE dbo.etl_control;

CREATE TABLE dbo.etl_control (
    BatchID INT IDENTITY(1,1) PRIMARY KEY,
    SourceFileName NVARCHAR(512),
    PackageName NVARCHAR(256),
    StartTime DATETIME2,
    EndTime DATETIME2,
    RowCount INT,
    ErrorCount INT,
    Status NVARCHAR(50), -- Started, Succeeded, Failed
    Message NVARCHAR(2000),
    CreatedBy NVARCHAR(128) DEFAULT SUSER_SNAME()
);

PRINT 'Created etl_control table.';

-- Views to simplify Power BI model

-- Current records view
IF OBJECT_ID('dbo.vw_Amazon_Current','V') IS NOT NULL
    DROP VIEW dbo.vw_Amazon_Current;
GO

CREATE VIEW dbo.vw_Amazon_Current
AS
SELECT *
FROM dbo.fct_Amazon
WHERE IsCurrent = 1;
GO

-- Join with date dimension (assuming ColX holds date, adjust accordingly)
IF OBJECT_ID('dbo.vw_Amazon_WithDate','V') IS NOT NULL
    DROP VIEW dbo.vw_Amazon_WithDate;
GO

CREATE VIEW dbo.vw_Amazon_WithDate
AS
SELECT f.*, d.DateKey, d.FullDate
FROM dbo.vw_Amazon_Current f
LEFT JOIN dbo.dimDate d
    ON CAST(f.Col10 AS DATE) = d.FullDate; -- adjust Col10 to your date column
GO

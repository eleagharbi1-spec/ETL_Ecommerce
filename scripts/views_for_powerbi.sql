-- Views to simplify Power BI model

-- Current records view
CREATE OR ALTER VIEW dbo.vw_Amazon_Current
AS
SELECT *
FROM dbo.fct_Amazon
WHERE IsCurrent = 1;

-- Join with date dimension (assuming Col10 holds date, adjust accordingly)
CREATE OR ALTER VIEW dbo.vw_Amazon_WithDate
AS
SELECT f.*, d.DateKey, d.FullDate
FROM dbo.vw_Amazon_Current f
LEFT JOIN dbo.dimDate d
    ON TRY_CAST(f.Col10 AS DATE) = d.FullDate; -- adjust Col10 to your date column

-- Create a persistent Date dimension table
-- Adjust rangeStart/rangeEnd as needed
DECLARE @StartDate DATE = '2018-01-01';
DECLARE @EndDate DATE = '2030-12-31';

IF OBJECT_ID('dbo.dimDate','U') IS NOT NULL
    DROP TABLE dbo.dimDate;

;WITH dates AS (
    SELECT @StartDate AS [Date]
    UNION ALL
    SELECT DATEADD(DAY, 1, [Date])
    FROM dates
    WHERE [Date] < @EndDate
)
SELECT
    ROW_NUMBER() OVER (ORDER BY [Date]) AS DateKey,
    [Date] AS FullDate,
    YEAR([Date]) AS [Year],
    MONTH([Date]) AS [MonthNumber],
    DATENAME(MONTH,[Date]) AS MonthName,
    DATEPART(QUARTER,[Date]) AS QuarterNumber,
    'Q' + CAST(DATEPART(QUARTER,[Date]) AS VARCHAR(1)) + ' ' + CAST(YEAR([Date]) AS VARCHAR(4)) AS QuarterLabel,
    DATENAME(WEEKDAY,[Date]) AS WeekDayName,
    DATEPART(WEEK,[Date]) AS WeekOfYear,
    CASE WHEN MONTH([Date]) IN (1,2,3) THEN 'Q1'
         WHEN MONTH([Date]) IN (4,5,6) THEN 'Q2'
         WHEN MONTH([Date]) IN (7,8,9) THEN 'Q3'
         ELSE 'Q4' END AS QuarterName
INTO dbo.dimDate
FROM dates
OPTION (MAXRECURSION 0);

PRINT 'Created dimDate';

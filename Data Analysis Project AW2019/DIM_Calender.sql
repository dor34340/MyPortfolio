-- Cleansed DIM DateTable -- 
SELECT 
  [DateKey] AS DATE, 
  [FullDateAlternateKey],
   -- ,[DayNumberOfWeek]
  [EnglishDayNameOfWeek] AS DAY,
  --,[SpanishDayNameOfWeek]
  --,[FrenchDayNameOfWeek]
  --,[DayNumberOfMonth]
  --,[DayNumberOfYear]
  [WeekNumberOfYear] AS WeekNr, 
  [EnglishMonthName] AS Month, 
  LEFT([EnglishMonthName], 3) AS MonthShort,
  --,[SpanishMonthName]
  --,[FrenchMonthName]
  [MonthNumberOfYear] AS MonthNr, 
  [CalendarQuarter] AS  Quarter, 
  [CalendarYear] AS YEAR
  --,[CalendarSemester]
  --,[FiscalQuarter]
  --,[FiscalYear]
  --,[FiscalSemester]
FROM 
  [AdventureWorksDW2019].[dbo].[DimDate]
WHERE [CalendarYear] >= 2019

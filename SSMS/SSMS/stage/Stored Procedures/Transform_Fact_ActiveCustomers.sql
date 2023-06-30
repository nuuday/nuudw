
CREATE PROCEDURE [stage].[Transform_Fact_ActiveCustomers]
	@JobIsIncremental BIT			
AS 


DECLARE @TheDate DATETIME = (SELECT DATEADD(DAY, 1, CONVERT(DATE, MAX(ActiveCustomersCountDate))) FROM Fact.ActiveCustomers)
DECLARE @MaxDate DATETIME = (SELECT CONVERT(DATE, DATEADD(DAY, -1, GETDATE())))

DROP TABLE IF EXISTS #ActiveCustomers
CREATE TABLE #ActiveCustomers (ActiveCount INT,TheDate DATETIME)
  
WHILE @TheDate <= @MaxDate
BEGIN

	INSERT INTO #ActiveCustomers ( ActiveCount, TheDate )
	SELECT
		COUNT( DISTINCT LID ) ActiveCount,
		@TheDate
	FROM [sourceNuudlColumbus].[AFTALE_LID_History] a
	WHERE
		1 = 1
		AND @TheDate >= [DWValidFromDate]
		AND @TheDate <= [DWValidToDate]
		AND LID_STATUS IN ('A')
		AND AENDRINGSSTATUS <> 'H'

	SET @TheDate = DATEADD( DAY, 1, @TheDate )

END

TRUNCATE TABLE [stage].[Fact_ActiveCustomers]

INSERT INTO stage.[Fact_ActiveCustomers] WITH (TABLOCK) ( CalendarKey, ActiveCustomersCountDate, ActiveCustomersCount )
SELECT
	TheDate AS CalendarKey,
	TheDate AS ActiveCustomersCountDate,
	ActiveCount AS ActiveCustomersCount
FROM #ActiveCustomers
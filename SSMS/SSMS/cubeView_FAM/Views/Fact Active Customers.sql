
CREATE VIEW [cubeView_FAM].[Fact Active Customers]
AS
SELECT
	[CalendarID],
	[ActiveCustomersCountDate],
	[ActiveCustomersCount]
FROM [factView].[Active Customers]
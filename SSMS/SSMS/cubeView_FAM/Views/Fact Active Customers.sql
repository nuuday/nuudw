CREATE VIEW cubeView_FAM.[Fact Active Customers]
AS
SELECT
	[CalendarID],
	[ActiveCustomersCountDate],
	[ActiveCustomersCount],
	[DWCreatedDate],
	[DWModifiedDate]
FROM [factView].[Active Customers]
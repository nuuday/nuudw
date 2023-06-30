CREATE VIEW [factView].[Active Customers] 
AS
SELECT
	[CalendarID]
	,[ActiveCustomersCountDate]
	,[ActiveCustomersCount]
	,[DWCreatedDate]
	,[DWModifiedDate]
	
FROM [fact].[ActiveCustomers]
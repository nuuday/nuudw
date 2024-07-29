CREATE VIEW [dimView].[Customer] 
AS
SELECT
	[CustomerID]
	,[CustomerKey] AS [CustomerKey]
	,[CustomerNumber] AS [CustomerNumber]
	,[CustomerName] AS [CustomerName]
	,[CustomerSegment] AS [CustomerSegment]
	,[CustomerStatus] AS [CustomerStatus]
	,[CustomerMigrationSource] AS [CustomerMigrationSource]
	,[CustomerMigrationDate] AS [CustomerMigrationDate]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[Customer]
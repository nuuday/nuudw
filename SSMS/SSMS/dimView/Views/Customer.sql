CREATE VIEW [dimView].[Customer] 
AS
SELECT
	[CustomerID]
	,[CustomerKey] AS [CustomerKey]
	,[CustomerName] AS [CustomerName]
	,[CustomerSegment] AS [CustomerSegment]
	,[CustomerStatus] AS [CustomerStatus]
	,[PartyRoleType] AS [PartyRoleType]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[Customer]
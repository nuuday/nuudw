CREATE VIEW [dimView].[Subscription] 
AS
SELECT
	[SubscriptionID]
	,[SubscriptionKey] AS [SubscriptionKey]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[Subscription]
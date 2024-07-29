CREATE VIEW [dimView].[Subscription] 
AS
SELECT
	[SubscriptionID]
	,[SubscriptionKey] AS [SubscriptionKey]
	,[FamilyBundle] AS [FamilyBundle]
	,[BundleType] AS [BundleType]
	,[SubscriptionValidFromDate] AS [SubscriptionValidFromDate]
	,[SubscriptionValidToDate] AS [SubscriptionValidToDate]
	,[SubscriptionIsCurrent] AS [SubscriptionIsCurrent]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[Subscription]
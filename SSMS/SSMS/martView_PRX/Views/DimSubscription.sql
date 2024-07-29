

CREATE VIEW [martView_PRX].[DimSubscription]
AS
SELECT 
	[SubscriptionID],
	[SubscriptionKey],
	FamilyBundle,
	BundleType
FROM [dimView].[Subscription]
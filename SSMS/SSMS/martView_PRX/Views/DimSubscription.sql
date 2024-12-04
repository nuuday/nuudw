﻿





CREATE VIEW [martView_PRX].[DimSubscription]
AS
SELECT 
	[SubscriptionID],
	[SubscriptionKey],
	[SubscriptionOriginalKey],
	FamilyBundle,
	BundleType,
	[BundleTypeSimpel],
	SubscriptionValidFromDate,
	SubscriptionValidToDate,
	SubscriptionIsCurrent,
	DWValidFromDate,
	DWValidToDate,
	DWIsCurrent,
	DWIsDeleted
FROM [dimView].[Subscription]
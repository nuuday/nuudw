﻿






CREATE VIEW [martView_PRX].[DimSubscription]
AS
SELECT 
	[SubscriptionID],
	[SubscriptionKey],
	[SubscriptionOriginalKey],
	FamilyBundle,
	BundleType,
	BundleTypeSimple,
	SubscriptionValidFromDate,
	SubscriptionValidToDate,
	SubscriptionIsCurrent,
	DWValidFromDate,
	DWValidToDate,
	DWIsCurrent,
	DWIsDeleted
FROM [dimView].[Subscription]
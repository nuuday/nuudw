
CREATE PROCEDURE [stage].[Transform_Dim_Subscription]
	@JobIsIncremental BIT			
AS 


DROP TABLE IF EXISTS #subscriptions
SELECT 
	ROW_NUMBER() OVER (ORDER BY a.NUUDL_ValidFrom) ID,
	CONVERT( NVARCHAR(36), a.id ) AS SubscriptionKey,
	ISNULL(JSON_VALUE(a.item, '$.businessGroup.id'),'?') AS FamilyBundle,
	ISNULL(
		CASE
			WHEN b.extended_parameters_json_offeringBusinessType = 'MOBILE_VOICE' THEN 
				CASE
					WHEN JSON_VALUE(a.item, '$.businessGroup.id') IS NULL THEN 'Standalone'
					ELSE LTRIM( REPLACE( a.item_name, b.name, '' ) )
				END
		END
		, '?') AS BundleType,
	a.active_from_CET AS ValidFromDate
INTO #subscriptions
FROM [sourceNuudlDawnView].ibsitemshistory_History a
INNER JOIN [sourceNuudlNetCrackerView].[pimnrmlproductoffering_History] b
	ON b.id = a.item_offeringId 
WHERE  1=1
	AND a.item_offeringId IS NOT NULL
	AND a.state IN ('ACTIVE','PLANNED')
	--AND a.id = '9c6a2902-2ff0-4a88-a7f9-9334e598d0c9'


DROP TABLE IF EXISTS #subscriptions_2
SELECT 
	*
	,CAST(LEAD(a.ValidFromDate,1) OVER (PARTITION BY a.SubscriptionKey ORDER BY a.ValidFromDate) as date) LeadValidFrom
INTO #subscriptions_2
FROM #subscriptions a


CREATE CLUSTERED INDEX CLIX ON #subscriptions (SubscriptionKey, ValidFromDate)


TRUNCATE TABLE [stage].[Dim_Subscription]


;WITH daily AS (

	SELECT 
		*
		,LAG(ID,1) OVER (PARTITION BY SubscriptionKey ORDER BY ValidFromDate) PreviousID
	FROM #subscriptions_2
	WHERE ValidFromDate <> ISNULL(LeadValidFrom,'1900-01-01')

)
, daily_collapsed AS (

	SELECT 
		c.*
	FROM daily c
	LEFT JOIN daily p ON p.ID = c.PreviousID
	CROSS APPLY (
		SELECT COUNT(*) Cnt
		FROM (
			SELECT c.FamilyBundle, c.BundleType
			UNION 
			SELECT p.FamilyBundle, p.BundleType
		) q
	) change
	WHERE Change.Cnt=2

)

INSERT INTO stage.[Dim_Subscription] WITH (TABLOCK) (SubscriptionValidFromDate, SubscriptionValidToDate, SubscriptionIsCurrent, SubscriptionKey, FamilyBundle, BundleType)
SELECT 
	ValidFromDate
	, ISNULL(LEAD(ValidFromDate,1) OVER (PARTITION BY SubscriptionKey ORDER BY ValidFromDate),'9999-12-31') ValidToDate
	, CASE WHEN LEAD(ValidFromDate,1) OVER (PARTITION BY SubscriptionKey ORDER BY ValidFromDate) IS NULL THEN 1 ELSE 0 END IsCurrent
	, SubscriptionKey
	, FamilyBundle
	, BundleType
FROM daily_collapsed
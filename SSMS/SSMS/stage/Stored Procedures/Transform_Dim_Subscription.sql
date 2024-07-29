
CREATE PROCEDURE [stage].[Transform_Dim_Subscription]
	@JobIsIncremental BIT			
AS 


DROP TABLE IF EXISTS #subscriptions
SELECT 
	ROW_NUMBER() OVER (ORDER BY a.NUUDL_ValidFrom) ID,
	CONVERT( NVARCHAR(36), a.id ) AS SubscriptionKey,
	JSON_VALUE(a.item, '$.businessGroup.id') AS FamilyBundle,
	CASE
		WHEN b.extended_parameters_json_offeringBusinessType = 'MOBILE_VOICE' THEN 
			CASE
				WHEN JSON_VALUE(a.item, '$.businessGroup.id') IS NULL THEN 'Standalone'
				ELSE LTRIM( REPLACE( a.item_name, b.name, '' ) )
			END
	END AS BundleType,
	a.NUUDL_ValidFrom AS ValidFromDate,
	a.NUUDL_ValidTo AS ValidToDate,
	CAST(LEAD(a.NUUDL_ValidFrom,1) OVER (PARTITION BY a.id ORDER BY a.NUUDL_ValidFrom) as date) LeadValidFrom
INTO #subscriptions
FROM [sourceNuudlDawnView].ibsitemshistory_History a
LEFT JOIN [sourceNuudlNetCrackerView].[pimnrmlproductoffering_History] b
	ON b.id = a.item_offeringId 
WHERE  1=1
	AND a.state IN ('ACTIVE','PLANNED')
	--AND a.id = '00dc2aed-3b87-4abc-be40-59f4f68e05da'


CREATE CLUSTERED INDEX CLIX ON #subscriptions (SubscriptionKey, ValidFromDate)


TRUNCATE TABLE [stage].[Dim_Subscription]


;WITH daily AS (

	SELECT 
		*
		,LAG(ID,1) OVER (PARTITION BY SubscriptionKey ORDER BY ValidFromDate) PreviousID
	FROM #subscriptions
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
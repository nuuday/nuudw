
CREATE PROCEDURE [stage].[Transform_Dim_Subscription]
	@JobIsIncremental BIT			
AS 


DROP TABLE IF EXISTS #subscriptions
CREATE TABLE #subscriptions (
	ID int IDENTITY(1,1),
	SubscriptionKey nvarchar(36),
	FamilyBundle nvarchar(100),
	BundleType NVARCHAR(100),
	ValidFromDate datetime2(0),
	rn int,
	daily_rn_desc int
)

INSERT INTO #subscriptions (SubscriptionKey, FamilyBundle, BundleType, ValidFromDate, rn, daily_rn_desc)
SELECT 
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
	CAST(a.active_from_CET as datetime2(0)) AS ValidFromDate,
	DENSE_RANK() OVER (PARTITION BY a.id ORDER BY CAST(a.active_from_CET as datetime2(0))) rn,
	ROW_NUMBER() OVER (PARTITION BY a.id, CAST(a.active_from_CET as datetime2(0)) ORDER BY a.active_from_CET DESC) daily_rn_desc
FROM [sourceNuudlDawnView].ibsitemshistory_History a
INNER JOIN [sourceNuudlNetCrackerView].[pimnrmlproductoffering_History] b
	ON b.id = a.item_offeringId 
WHERE  1=1
	--AND a.item_parentId IS NULL
	AND a.item_offeringId IS NOT NULL
	AND a.state IN ('ACTIVE','PLANNED')
	--AND a.id = '60e05fb6-1194-4531-9f86-7e70ac3d4594'
	

INSERT INTO #subscriptions (SubscriptionKey, FamilyBundle, BundleType, ValidFromDate, rn, daily_rn_desc)
SELECT 
	CONVERT( NVARCHAR(36), a.id ) AS SubscriptionKey,
	'?' AS FamilyBundle,
	'?' AS BundleType,
	'1900-01-01' AS ValidFromDate,
	1 rn,
	1 daily_rn_desc
FROM [sourceNuudlDawnView].ibsitemshistory_History a
WHERE NOT EXISTS (SELECT * FROM #subscriptions WHERE SubscriptionKey = a.id)
	AND a.item_parentId IS NULL


DROP TABLE IF EXISTS #subscriptions_2
SELECT 
	ID
	, SubscriptionKey
	, FamilyBundle
	, BundleType
	, IIF(rn=1,'1900-01-01',ValidFromDate) ValidFromDate
	,CAST(LEAD(a.ValidFromDate,1) OVER (PARTITION BY a.SubscriptionKey ORDER BY a.ValidFromDate) as datetime2(0)) LeadValidFrom
INTO #subscriptions_2
FROM #subscriptions a
WHERE daily_rn_desc=1


CREATE CLUSTERED INDEX CLIX ON #subscriptions (SubscriptionKey, ValidFromDate)


TRUNCATE TABLE [stage].[Dim_Subscription]


;WITH daily AS (

	SELECT 
		*
		,LAG(ID,1) OVER (PARTITION BY SubscriptionKey ORDER BY ValidFromDate) PreviousID
	FROM #subscriptions_2
	WHERE ValidFromDate <> ISNULL(LeadValidFrom,'9999-12-31')

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
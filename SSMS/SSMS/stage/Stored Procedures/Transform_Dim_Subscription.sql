


CREATE PROCEDURE [stage].[Transform_Dim_Subscription]
	@JobIsIncremental BIT			
AS 


DROP TABLE IF EXISTS #Subscriptions
CREATE TABLE #Subscriptions (
	SubscriptionKey NVARCHAR(36) NOT NULL,
	SubscriptionParentKey NVARCHAR(36) NULL,
	SubscriptionOriginalKey NVARCHAR(36) NULL
)

CREATE UNIQUE CLUSTERED INDEX CLIX ON #Subscriptions (SubscriptionKey)

INSERT INTO #Subscriptions (SubscriptionKey, SubscriptionParentKey)
SELECT
	COALESCE(i.item_parentId, i.id) AS SubscriptionKey,
	MAX(
		CASE
			WHEN
				i.item_productRelationship_relationshipType = 'changeOwnership'
				AND i.state <> 'DISCONNECTED'
				AND i.item_parentId IS NULL THEN i.item_productRelationship_productId
			ELSE null
		END
	) SubscriptionParentKey
FROM [sourceNuudlDawnView].[ibsitemshistory_History] i
WHERE 1=1
	AND i.NUUDL_IsLatest = 1
--	AND (i.item_parentId IN ('f8abd6d9-a845-4af4-aa2e-e3a438466a01') OR i.id IN ('f8abd6d9-a845-4af4-aa2e-e3a438466a01'))
GROUP BY COALESCE(i.item_parentId, i.id)


;WITH RecursiveCTE AS (

	-- Base case: select all rows where SubscriptionParentKey is null (they are their own original)
	SELECT 
		SubscriptionKey,
		SubscriptionParentKey,
		SubscriptionKey AS SubscriptionOriginalKey -- they are their own original
	FROM #Subscriptions
	WHERE
		SubscriptionParentKey IS NULL
		AND SubscriptionKey IN (SELECT SubscriptionParentKey FROM #Subscriptions)

	UNION ALL

	-- Recursive case: find the parent subscription and continue until the oldest parent is found
	SELECT 
		s.SubscriptionKey,
		s.SubscriptionParentKey,
		r.SubscriptionOriginalKey -- keep the oldest original key found in the recursion
	FROM #Subscriptions s
	INNER JOIN RecursiveCTE r
		ON s.SubscriptionParentKey = r.SubscriptionKey

)

-- Now update the table with the calculated SubscriptionOriginalKey
UPDATE s
SET SubscriptionOriginalKey = COALESCE(r.SubscriptionOriginalKey, s.SubscriptionKey)
FROM #Subscriptions s
LEFT JOIN RecursiveCTE r
    ON s.SubscriptionKey = r.SubscriptionKey


DROP TABLE IF EXISTS #subscriptions_detailed
CREATE TABLE #subscriptions_detailed (
	ID int IDENTITY(1,1),
	SubscriptionKey nvarchar(36),
	SubscriptionOriginalKey nvarchar(36),
	FamilyBundle nvarchar(100),
	BundleType NVARCHAR(100),
	ValidFromDate datetime2(0),
	rn int,
	daily_rn_desc int,
	FirstProductId NVARCHAR(36),
	ProductId NVARCHAR(36)
)

INSERT INTO #subscriptions_detailed (SubscriptionKey, SubscriptionOriginalKey, FamilyBundle, BundleType, ValidFromDate, rn, daily_rn_desc, FirstProductId, ProductId)
SELECT 
	s.SubscriptionKey,
	s.SubscriptionOriginalKey,
	ISNULL(a.item_businessGroup_id,'?') AS FamilyBundle,
	ISNULL(
		CASE
			WHEN b.extended_parameters_json_offeringBusinessType = 'MOBILE_VOICE' THEN 
				CASE
					WHEN a.item_businessGroup_id IS NULL THEN 'Standalone'
					ELSE LTRIM( REPLACE( a.item_name, b.name, '' ) )
				END
		END
		, '?') AS BundleType,
	CAST(a.active_from_CET as datetime2(0)) AS ValidFromDate,
	DENSE_RANK() OVER (PARTITION BY a.id ORDER BY CAST(a.active_from_CET as datetime2(0))) rn,
	ROW_NUMBER() OVER (PARTITION BY a.id, CAST(a.active_from_CET as datetime2(0)) ORDER BY a.active_from_CET DESC) daily_rn_desc,
	FIRST_VALUE(item_offeringId) OVER (PARTITION BY a.id ORDER BY CAST(a.active_from_CET as datetime2(0))) FirstProductId,
	b.id
FROM [sourceNuudlDawnView].ibsitemshistory_History a
INNER JOIN #Subscriptions s ON s.SubscriptionKey = a.id
LEFT JOIN [sourceNuudlNetCrackerView].[pimnrmlproductoffering_History] b
	ON b.id = a.item_offeringId 
WHERE  1=1
	AND a.state IN ('ACTIVE','PLANNED') and a.NUUDL_IsLatest=1
--	AND a.id = '009a2514-ebec-44ee-adde-d1d920418e65'

/*
There are cases where we have an ACTIVE state without a product key due to change on SLO level. We wan't to filter these out.
At the same time we want to make sure we get subscriptions that never have had a valid product key (no matter the reason).
*/
DELETE FROM s
FROM #subscriptions_detailed s
WHERE 1=1
	AND ProductId IS NULL 
	AND FirstProductId IS NOT NULL
	AND rn <> 1

INSERT INTO #subscriptions_detailed (SubscriptionKey, SubscriptionOriginalKey, FamilyBundle, BundleType, ValidFromDate, rn, daily_rn_desc)
SELECT 
	CONVERT( NVARCHAR(36), a.id ) AS SubscriptionKey,
	CONVERT( NVARCHAR(36), a.id ) AS SubscriptionOriginalKey,
	'?' AS FamilyBundle,
	'?' AS BundleType,
	'1900-01-01' AS ValidFromDate,
	1 rn,
	1 daily_rn_desc
FROM [sourceNuudlDawnView].ibsitemshistory_History a
WHERE NOT EXISTS (SELECT * FROM #subscriptions WHERE SubscriptionKey = a.id)
	AND a.item_parentId IS NULL


DROP TABLE IF EXISTS #subscriptions_detailed_2
SELECT 
	ID
	, SubscriptionKey
	, SubscriptionOriginalKey
	, FamilyBundle
	, BundleType
	, IIF(rn=1,'1900-01-01',ValidFromDate) ValidFromDate
	,CAST(LEAD(a.ValidFromDate,1) OVER (PARTITION BY a.SubscriptionKey ORDER BY a.ValidFromDate) as datetime2(0)) LeadValidFrom
INTO #subscriptions_detailed_2
FROM #subscriptions_detailed a
WHERE daily_rn_desc=1


CREATE CLUSTERED INDEX CLIX ON #subscriptions_detailed_2 (SubscriptionKey, ValidFromDate)


TRUNCATE TABLE [stage].[Dim_Subscription]


;WITH daily AS (

	SELECT 
		*
		,LAG(ID,1) OVER (PARTITION BY SubscriptionKey ORDER BY ValidFromDate) PreviousID
	FROM #subscriptions_detailed_2
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

INSERT INTO stage.[Dim_Subscription] WITH (TABLOCK) (SubscriptionValidFromDate, SubscriptionValidToDate, SubscriptionIsCurrent, SubscriptionKey, SubscriptionOriginalKey, FamilyBundle, BundleType, BundleTypeSimple)
SELECT 
	ValidFromDate
	, ISNULL(LEAD(ValidFromDate,1) OVER (PARTITION BY SubscriptionKey ORDER BY ValidFromDate),'9999-12-31') ValidToDate
	, CASE WHEN LEAD(ValidFromDate,1) OVER (PARTITION BY SubscriptionKey ORDER BY ValidFromDate) IS NULL THEN 1 ELSE 0 END IsCurrent
	, SubscriptionKey
	, SubscriptionOriginalKey
	, FamilyBundle
	, BundleType
	, CASE
		WHEN LOWER(BundleType) LIKE 'standalone%' OR 
			 LOWER(BundleType) LIKE 'basis%' OR 
			 LOWER(BundleType) LIKE 'primary%' OR
			 --BundleType = '?' OR   
			 BundleType LIKE '#%'
		THEN 'Basis'
		WHEN LOWER(BundleType) LIKE 'ekstra%' OR 
			 LOWER(BundleType) LIKE 'secondary%' 
		THEN 'Ekstra'
		ELSE '?' 
	 END AS BundleTypeSimple
FROM daily_collapsed
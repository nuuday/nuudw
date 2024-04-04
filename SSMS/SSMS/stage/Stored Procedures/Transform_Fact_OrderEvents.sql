
CREATE PROCEDURE [stage].[Transform_Fact_OrderEvents]
	@JobIsIncremental BIT			
AS 

-- Prepare billing contact data for next query
DROP TABLE IF EXISTS #billing_contact_details
SELECT DISTINCT
	cm.id Householdkey,
	cma.ref_id AS customer_id,
	CONCAT( ISNULL( cm.street1, '' ), ';', ISNULL( cm.street2, '' ), ';', ISNULL( cm.postcode, '' ), ';', ISNULL( cm.city, '' ) ) AddressBillingKey
INTO #billing_contact_details
FROM [sourceNuudlNetCrackerView].[cimcontactmediumassociation_History] cma
INNER JOIN [sourceNuudlNetCrackerView].[cimcontactmedium_History] cm
	ON cm.id = cma.contact_medium_id
		AND cm.is_current = 1
		AND type_of_contact_method = 'Billing contact details'
WHERE
	cma.is_current = 1

CREATE UNIQUE CLUSTERED INDEX CLIX ON #billing_contact_details (customer_id)


-- Fetch first part of data connected to items history 
DROP TABLE IF EXISTS #all_lines
SELECT DISTINCT
	COALESCE(i.item_json_parentId, i.id) AS SubscriptionKey,
	i.id AS SubscriptionChildKey,
	CAST(i.active_from_CET AS Date) AS CalendarKey,
	LEFT( CONVERT( VARCHAR, i.active_from_CET, 108 ), 8 ) AS TimeKey,
	--i.active_to AS CalendarToKey,
	i.item_json_offeringId AS ProductKey,
	CASE
		WHEN pf.name = 'Mobile Voice Offline' THEN 'Mobile Voice'
		WHEN pf.name = 'Mobile Broadband Offline' THEN 'Mobile Broadband'
		ELSE pf.name
	END AS ProductType,
	i.item_json_offeringName AS ProductName,
	po.weight AS ProductWeight,
	cim.customer_number AS CustomerKey,
	ev.OrderEventKey,
	ev.OrderEventName,
	i.state CurrentState,
	quote.number AS QuoteKey,
--	i.item_json_rootId root_id,
	i.item_json_distributionChannelId AS SalesChannelKey,
	acc.account_num AS BillingAccountKey,
	CONVERT( NVARCHAR(20), TRIM(TRANSLATE( chr.value_json__corrupt_record, '["]', '   ' )) ) AS PhoneDetailkey,
	CASE WHEN item_json_parentId IS NULL THEN 1 ELSE 0 END IsTLO,
	i.item_json_customerId AS customer_id,
	i.active_from_CET,
	CAST(i.item_json_expirationDate as datetime2(0)) AS expiration_date
INTO #all_lines
FROM [sourceNuudlNetCrackerView].[ibsitemshistory_History] i
LEFT JOIN dim.OrderEvent ev 
	ON ev.SourceEventName = i.[state]
-- reference to CustomerKey
LEFT JOIN [sourceNuudlNetCrackerView].[cimcustomer_History] cim
	ON cim.id = i.item_json_customerId AND cim.is_current = 1
-- reference to Quotekey,
LEFT JOIN [sourceNuudlNetCrackerView].[qssnrmlquote_History] quote
	ON quote.id = i.item_json_quoteId AND quote.is_current = 1
LEFT JOIN [sourceNuudlNetCrackerView].[nrmaccountkeyname_History] acc
	ON acc.name = i.item_json_accountRef_json_refId 
-- reference to PhoneDetailkey, SLO will have TLO phone number
LEFT JOIN [sourceNuudlNetCrackerView].[ibsnrmlcharacteristic_History] chr
	ON chr.product_instance_id = COALESCE(i.item_json_parentId, i.id)
		AND chr.name = 'International Phone Number'
LEFT JOIN [sourceNuudlNetCrackerView].[pimnrmlproductoffering_History] po
	ON po.id = i.item_json_offeringId
LEFT JOIN [sourceNuudlNetCrackerView].[pimnrmlproductfamily_History] pf
	ON pf.id = po.product_family_id
WHERE 1=1
	-- Compensate for duplicate rows
	AND CASE WHEN i.state = 'COMPLETED' THEN item_json_accountRef_json_refId ELSE '' END IS NOT NULL 
	--we are excluding those subscriptions because of data issues due to testing activities in production
	AND i.id NOT IN ('b5beb355-0379-41f2-aaad-47297c9548cb', '39476242-7ab7-467e-b88a-b3968a8cb7e9') 


-- Fetch second part
-- Split in two queries due to performance
DROP TABLE IF EXISTS #all_lines_2
SELECT 
	al.*,
	COALESCE(pp.ProductParentKey, pp2.ProductParentKey) AS ProductParentKey,
	bcd.AddressBillingKey,
	bcd.Householdkey,
	ISNULL(LAG( al.ProductKey ) OVER (PARTITION BY al.SubscriptionKey, al.ProductType ORDER BY al.active_from_CET),'') AS  PreviousProductKey,
	ISNULL(LAG( al.CurrentState ) OVER (PARTITION BY al.SubscriptionKey, al.ProductKey ORDER BY al.active_from_CET),'') AS  PreviousState,
	CASE 
		WHEN LAG( cpd.start_dat_CET ) OVER (PARTITION BY al.SubscriptionKey, al.ProductKey ORDER BY al.active_from_CET) IS NULL THEN cpd.start_dat_CET
	END AS RGU_StartDate,
	CASE 
		WHEN LAG( cpd.start_dat_CET ) OVER (PARTITION BY al.SubscriptionKey, al.ProductKey ORDER BY al.active_from_CET) IS NULL THEN cpd.end_dat_CET
	END AS RGU_EndDate
INTO #all_lines_2
FROM #all_lines al
OUTER APPLY (
	SELECT TOP 1 ProductKey AS ProductParentKey
	FROM #all_lines
	WHERE QuoteKey = al.QuoteKey
		AND SubscriptionKey = al.SubscriptionKey
		AND IsTLO = 1
	ORDER BY active_from_CET DESC
) pp
OUTER APPLY (
	SELECT TOP 1 ProductKey AS ProductParentKey
	FROM #all_lines
	WHERE active_from_CET <= al.active_from_CET
		AND SubscriptionKey = al.SubscriptionKey
		AND IsTLO = 1
	ORDER BY active_from_CET DESC
) pp2
LEFT JOIN #billing_contact_details bcd
	ON bcd.customer_id = al.customer_id
LEFT JOIN [sourceNuudlNetCrackerView].[nrmcusthasproductkeyname_History] kn
	ON kn.name = al.SubscriptionKey
LEFT JOIN [sourceNuudlNetCrackerView].[nrmcustproductdetails_History] cpd
	ON cpd.product_seq = kn.product_seq
		AND cpd.customer_ref = kn.customer_ref
		AND (cpd.product_label = al.ProductName OR cpd.override_product_name = al.ProductName)
		AND al.active_from_CET BETWEEN cpd.start_dat AND ISNULL(cpd.end_dat,'9999-12-31')
WHERE 1=1
	AND OrderEventKey IS NOT NULL
--	AND SubscriptionKey = '1ed59543-b526-4e7f-a069-5e5c03fd95d4'
--	AND IsTLO = 1
--ORDER BY active_from_CET, IsTLO DESC


-- Get Account from top level offer
UPDATE t
SET BillingAccountKey = ca.BillingAccountKey
FROM #all_lines_2 t
CROSS APPLY (
	SELECT MAX(BillingAccountKey) BillingAccountKey
	FROM #all_lines_2
	WHERE SubscriptionKey = t.SubscriptionKey
	) ca
WHERE IsTLO = 0

-----------------------------------------------------------------------------------------------------------------------------
-- Filter out duplicate events. 
-- When a TLO appears several times due to changes on SLO level
-----------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #all_lines_filtered
SELECT *
INTO #all_lines_filtered
FROM #all_lines_2 al
WHERE 1=1
	AND (
		al.CurrentState <> al.PreviousState 
		OR (al.ProductKey <> al.PreviousProductKey AND IsTLO=1) /* keep lines where product shift back and forth between the same products */
		) 
--	AND SubscriptionKey = '1ed59543-b526-4e7f-a069-5e5c03fd95d4'
--	AND istlo=1
--ORDER BY active_from_CET

-----------------------------------------------------------------------------------------------------------------------------
-- We divide the Subscription into groups when the Product Type is changed on the TLO
-- Each grouping is considered as its own subscription when rules are applied
-----------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #all_lines_filtered_2
SELECT 
	SUM(ProductTypeChangeFlag) OVER (PARTITION BY SubscriptionKey ORDER BY active_from_CET) AS SubscriptionGroup,
	*
INTO #all_lines_filtered_2
FROM (
	SELECT 
		CASE 
			WHEN IsTLO = 1 AND ProductType <> LAG( ProductType ) OVER (PARTITION BY al.SubscriptionKey, IsTLO ORDER BY active_from_CET) THEN 1
			--WHEN IsTLO = 1 THEN 0
			ELSE 0
		END AS ProductTypeChangeFlag,
		*
	FROM #all_lines_filtered al
	WHERE 1=1
		--AND IsTLO = 1
		--AND SubscriptionKey ='b5f00442-6c45-4c82-93fe-b5394ee207ee'
) q
--ORDER BY active_from_CET, IsTLO DESC

-----------------------------------------------------------------------------------------------------------------------------
-- Add RGU events
-----------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #rgu_lines
SELECT DISTINCT
	CASE e.OrderEventName
		WHEN 'RGU Activated' THEN CAST(al.RGU_StartDate AS date)
		WHEN 'RGU Disconnected' THEN CAST(al.RGU_EndDate AS date)
	END AS CalendarKey,
	CASE e.OrderEventName
		WHEN 'RGU Activated' THEN LEFT( CONVERT( VARCHAR, RGU_StartDate, 108 ), 8 ) 
		WHEN 'RGU Disconnected' THEN LEFT( CONVERT( VARCHAR, RGU_EndDate, 108 ), 8 ) 
	END AS TimeKey,
	al.ProductKey, 
	al.ProductParentKey,
	al.CustomerKey,
	al.SubscriptionGroup,
	al.SubscriptionKey,
	al.QuoteKey,
	e.OrderEventKey,
	e.OrderEventName,
	al.ProductType,
	al.ProductName,
	al.SalesChannelKey,
	al.BillingAccountKey,
	al.PhoneDetailKey,
	al.AddressBillingKey,
	al.HouseHoldKey,
	al.IsTLO,
	al.active_from_CET
INTO #rgu_lines
FROM #all_lines_filtered_2 al
CROSS APPLY (
	SELECT *
	FROM dim.OrderEvent 
	WHERE OrderEventName IN ('RGU Activated', 'RGU Disconnected')
) e
WHERE 1=1
--	AND subscriptionkey='1ed59543-b526-4e7f-a069-5e5c03fd95d4'
	AND al.CurrentState IN ( 'ACTIVE', 'PLANNED')
--	AND IsTLO = 1

DELETE FROM #rgu_lines
WHERE CalendarKey IS NULL

-----------------------------------------------------------------------------------------------------------------------------
-- Add Commitment events
-----------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #commitment_lines
SELECT 
	CAST(al.expiration_date as date) AS CalendarKey,
	LEFT( CONVERT( VARCHAR, al.expiration_date, 108 ), 8 )  AS TimeKey,
	tlo.ProductKey, 
	tlo.ProductParentKey,
	al.CustomerKey,
	al.SubscriptionGroup,
	al.SubscriptionKey,
	al.QuoteKey,
	e.OrderEventKey,
	e.OrderEventName,
	tlo.ProductType,
	tlo.ProductName,
	al.SalesChannelKey,
	al.BillingAccountKey,
	al.PhoneDetailKey,
	al.AddressBillingKey,
	al.HouseHoldKey,
	tlo.IsTLO,
	al.active_from_CET
INTO #commitment_lines
FROM #all_lines_filtered_2 al
CROSS APPLY (
	SELECT *
	FROM dim.OrderEvent 
	WHERE OrderEventName = 'Offer Commitment End'
) e
CROSS APPLY (
	SELECT TOP 1 ProductKey, ProductParentKey, ProductName, ProductType, IsTLO
	FROM #all_lines_filtered
	WHERE SubscriptionKey = al.SubscriptionKey 
		AND active_from_CET <= al.active_from_CET
		AND CurrentState = 'ACTIVE'
		AND IsTLO = 1 
	ORDER BY active_from_CET DESC
) tlo
WHERE 1=1
	AND al.CurrentState = 'ACTIVE'
	AND al.ProductName = 'Commitment'
	AND NOT EXISTS (
		SELECT * 
		FROM #all_lines_filtered 
		WHERE SubscriptionKey = al.SubscriptionKey 
			AND ProductKey = al.ProductKey
			AND OrderEventName = 'Offer Disconnected'
			AND active_from_CET >= al.active_from_CET
		)
--	AND al.SubscriptionKey = 'cdbb8da4-74de-4aa5-8d36-3b0153907378'


-----------------------------------------------------------------------------------------------------------------------------
-- Add events do to change in product type and product
-----------------------------------------------------------------------------------------------------------------------------

-- Get all active lines
DROP TABLE IF EXISTS #active_lines
SELECT al.* 
	, LAG( ProductType ) OVER (PARTITION BY al.SubscriptionKey, IsTLO ORDER BY active_from_CET) PreviousProductType
	, LEAD( ProductType ) OVER (PARTITION BY  al.SubscriptionKey, IsTLO ORDER BY active_from_CET) NextProductType
	, LAG( ProductName ) OVER (PARTITION BY al.SubscriptionGroup, al.SubscriptionKey, al.ProductType ORDER BY active_from_CET) PreviousProductName
	, LEAD( ProductName ) OVER (PARTITION BY al.SubscriptionGroup, al.SubscriptionKey, al.ProductType ORDER BY active_from_CET) NextProductName
	, LEAD( ProductWeight ) OVER (PARTITION BY al.SubscriptionGroup, al.SubscriptionKey, al.ProductType ORDER BY active_from_CET) NextProductWeight
	, LEAD( CalendarKey ) OVER (PARTITION BY al.SubscriptionGroup, al.SubscriptionKey, al.ProductType ORDER BY active_from_CET) NextDate
	, LEAD( TimeKey ) OVER (PARTITION BY al.SubscriptionGroup, al.SubscriptionKey, al.ProductType ORDER BY active_from_CET) NextTime
	, LEAD( CalendarKey ) OVER (PARTITION BY al.SubscriptionKey, IsTLO ORDER BY active_from_CET) NextDateTLO
	, LEAD( TimeKey ) OVER (PARTITION BY al.SubscriptionKey, IsTLO ORDER BY active_from_CET) NextTimeTLO
INTO #active_lines
FROM #all_lines_filtered_2 al
WHERE al.CurrentState = 'ACTIVE'


-- Create Migration From lines
DROP TABLE IF EXISTS #migration_lines
SELECT 
	s.NextDate AS CalendarKey,
	s.NextTime AS TimeKey,
	s.ProductKey, 
	s.ProductParentKey,
	s.CustomerKey,
	s.SubscriptionGroup,
	s.SubscriptionKey,
	s.QuoteKey,
	e.OrderEventKey,
	e.OrderEventName,
	s.ProductType,
	s.ProductName,
	s.SalesChannelKey,
	s.BillingAccountKey,
	s.PhoneDetailKey,
	s.AddressBillingKey,
	s.HouseHoldKey,
	s.IsTLO,
	s.active_from_CET
INTO #migration_lines
FROM #active_lines s
CROSS APPLY (
	SELECT *
	FROM dim.OrderEvent 
	WHERE OrderEventName = 
		CASE	
			WHEN s.NextProductWeight > s.ProductWeight THEN 'Migration From Upgrade'
			WHEN s.NextProductWeight < s.ProductWeight THEN 'Migration From Downgrade'
			ELSE 'Migration From'
		END
) e
WHERE NextProductName <> ProductName
--	AND SubscriptionKey = 'b5f00442-6c45-4c82-93fe-b5394ee207ee'

-- Create Migration To lines
DROP TABLE IF EXISTS #change_lines
SELECT 
	s.CalendarKey,
	s.TimeKey,
	s.ProductKey, 
	s.ProductParentKey,
	s.CustomerKey,
	s.SubscriptionGroup,
	s.SubscriptionKey,
	s.QuoteKey,
	e.OrderEventKey,
	e.OrderEventName,
	s.ProductType,
	s.ProductName,
	s.SalesChannelKey,
	s.BillingAccountKey,
	s.PhoneDetailKey,
	s.AddressBillingKey,
	s.HouseHoldKey,
	s.IsTLO,
	s.active_from_CET
INTO #change_lines
FROM #active_lines s
CROSS APPLY (
	SELECT *
	FROM dim.OrderEvent 
	WHERE OrderEventName = 'Migration To'
) e
WHERE s.PreviousProductName <> s.ProductName 

-- Creating Offer Disconnected lines if the offer is migrated
DROP TABLE IF EXISTS #disconnect_lines_from_migrations
SELECT 
	s.CalendarKey,
	s.TimeKey,
	s.ProductKey, 
	s.ProductParentKey,
	s.CustomerKey,
	s.SubscriptionGroup,
	s.SubscriptionKey,
	s.QuoteKey,
	e.OrderEventKey,
	e.OrderEventName,
	s.ProductType,
	s.ProductName,
	s.SalesChannelKey,
	s.BillingAccountKey,
	s.PhoneDetailKey,
	s.AddressBillingKey,
	s.HouseHoldKey,
	s.IsTLO,
	s.active_from_CET
INTO #disconnect_lines_from_migrations
FROM #migration_lines s
CROSS APPLY (
	SELECT *
	FROM dim.OrderEvent 
	WHERE OrderEventName = 'Offer Disconnected'
) e
WHERE 1=1
	AND s.IsTLO = 1
--	AND SubscriptionKey = 'b5f00442-6c45-4c82-93fe-b5394ee207ee'


-- Creating Offer Disconnected if the Product Type is changed
DROP TABLE IF EXISTS #disconnect_lines_from_product_type_change
SELECT 
	s.NextDateTLO AS CalendarKey,
	s.NextTimeTLO AS TimeKey,
	s.ProductKey, 
	s.ProductParentKey,
	s.CustomerKey,
	s.SubscriptionGroup,
	s.SubscriptionKey,
	s.QuoteKey,
	e.OrderEventKey,
	e.OrderEventName,
	s.ProductType,
	s.NextProductType,
	s.ProductName,
	s.SalesChannelKey,
	s.BillingAccountKey,
	s.PhoneDetailKey,
	s.AddressBillingKey,
	s.HouseHoldKey,
	s.IsTLO,
	s.active_from_CET,
	1 AS NewSubscription
INTO #disconnect_lines_from_product_type_change
FROM #active_lines s
CROSS APPLY (
	SELECT *
	FROM dim.OrderEvent 
	WHERE OrderEventName = 'Offer Disconnected'
) e
WHERE 1=1
	AND s.IsTLO = 1
	AND s.ProductType <> s.NextProductType
--	AND SubscriptionKey = 'b5f00442-6c45-4c82-93fe-b5394ee207ee'

-- Create Offer Planned if the Product Type is changed
DROP TABLE IF EXISTS #planned_lines_from_product_type_change
SELECT 
	s.CalendarKey,
	s.TimeKey,
	s.ProductKey, 
	s.ProductParentKey,
	s.CustomerKey,
	s.SubscriptionGroup,
	s.SubscriptionKey,
	s.QuoteKey,
	e.OrderEventKey,
	e.OrderEventName,
	s.ProductType,
	s.ProductName,
	s.SalesChannelKey,
	s.BillingAccountKey,
	s.PhoneDetailKey,
	s.AddressBillingKey,
	s.HouseHoldKey,
	s.IsTLO,
	s.active_from_CET
INTO #planned_lines_from_product_type_change
FROM #active_lines s
CROSS APPLY (
	SELECT *
	FROM dim.OrderEvent 
	WHERE OrderEventName = 'Offer Planned'
) e
WHERE 1=1
	AND s.IsTLO = 1
	AND s.ProductType <> s.PreviousProductType


-----------------------------------------------------------------------------------------------------------------------------
-- Insert everyting into result set
-----------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #result
SELECT *
INTO #result
FROM (

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, CustomerKey, SubscriptionGroup, SubscriptionKey, QuoteKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, IsTLO, 1 Quantity
		,active_from_CET
	FROM #all_lines_filtered_2
	WHERE OrderEventKey IS NOT NULL
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, CustomerKey, SubscriptionGroup, SubscriptionKey, QuoteKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #migration_lines
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, CustomerKey, SubscriptionGroup, SubscriptionKey, QuoteKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #disconnect_lines_from_migrations

	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, CustomerKey, SubscriptionGroup, SubscriptionKey, QuoteKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #disconnect_lines_from_product_type_change

	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, CustomerKey, SubscriptionGroup, SubscriptionKey, QuoteKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #planned_lines_from_product_type_change
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, CustomerKey, SubscriptionGroup, SubscriptionKey, QuoteKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #change_lines
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, CustomerKey, SubscriptionGroup, SubscriptionKey, QuoteKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #commitment_lines
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, CustomerKey, SubscriptionGroup, SubscriptionKey, QuoteKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #rgu_lines

) q


-----------------------------------------------------------------------------------------------------------------------------
-- Set Quantity to zero to accommodate Gross Adds and Churn calculations
-----------------------------------------------------------------------------------------------------------------------------

UPDATE ra
SET Quantity = 0
--SELECT ra.*
FROM #result ra
WHERE 1=1
	AND ra.IsTLO = 1
	AND ra.OrderEventName IN ('RGU Activated', 'Offer Activated')
	AND EXISTS (
			SELECT * 
			FROM #result 
			WHERE SubscriptionKey = ra.SubscriptionKey 
				AND SubscriptionGroup = ra.SubscriptionGroup
				AND OrderEventName = ra.OrderEventName
				AND IsTLO = ra.IsTLO
				AND active_from_CET < ra.active_from_CET
	)
--	AND ra.SubscriptionKey = 'b5f00442-6c45-4c82-93fe-b5394ee207ee'

UPDATE ra
SET Quantity = 0
--SELECT ra.*
FROM #result ra
WHERE 1=1
	AND ra.IsTLO = 1
	AND ra.OrderEventName IN ('Offer Disconnected','RGU Disconnected')
	AND EXISTS (
		SELECT * 
		FROM #result 
		WHERE SubscriptionKey = ra.SubscriptionKey 
			AND SubscriptionGroup = ra.SubscriptionGroup
			AND OrderEventName = ra.OrderEventName
			AND IsTLO = ra.IsTLO
			AND active_from_CET > ra.active_from_CET
	)
--	AND ra.SubscriptionKey = 'b5f00442-6c45-4c82-93fe-b5394ee207ee'



/*
--SELECT *
--FROM #all_lines
--WHERE SubscriptionKey = '1ed59543-b526-4e7f-a069-5e5c03fd95d4'
--	AND IsTLO=1
--ORDER By 2, 3, IsTlo DESC

--SELECT *
--FROM #all_lines_filtered
--WHERE SubscriptionKey = 'b5f00442-6c45-4c82-93fe-b5394ee207ee'
--	AND IsTLO=1
--ORDER By 2, 3, IsTlo DESC

SELECT  *
FROM #result
WHERE SubscriptionKey = '54f8fed8-a117-4104-b02d-eabf3c40a0b9'
	AND IsTLO=1
--	AND OrderEventName IN ('Offer Disconnected')
ORDER By SubscriptionGroup, 1, 2, IsTlo DESC, OrderEventKey
--*/

-----------------------------------------------------------------------------------------------------------------------------
-- Truncate and insert into stage table
-----------------------------------------------------------------------------------------------------------------------------

TRUNCATE TABLE [stage].[Fact_OrderEvents]

INSERT INTO [stage].[Fact_OrderEvents] ([CalendarKey], [TimeKey], [ProductKey], [ProductParentKey], [CustomerKey], [SubscriptionKey], [QuoteKey], [OrderEventKey], [SalesChannelKey], [BillingAccountKey], 
	[PhoneDetailKey], [AddressBillingKey], [HouseHoldKey], [IsTLO], [Quantity])
SELECT
	CalendarKey,
	TimeKey,
	ProductKey,
	ProductParentKey,
	CustomerKey,
	SubscriptionKey,
	QuoteKey,
	OrderEventKey,
	SalesChannelKey,
	BillingAccountKey,
	PhoneDetailKey,
	AddressBillingKey,
	HouseHoldKey,
	IsTLO,
	Quantity
FROM #result
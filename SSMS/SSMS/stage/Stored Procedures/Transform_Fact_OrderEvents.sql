
CREATE PROCEDURE [stage].[Transform_Fact_OrderEvents]
	@JobIsIncremental BIT			
AS 

-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-- 1. Collecting core events based items history (product instance) states together with dimensional data
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------

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
	CAST(i.item_json_expirationDate as datetime2(0)) AS expiration_date,
	i.item_json_quoteId,
	CASE WHEN po.extended_parameters_json_deviceType IS NULL THEN 0 ELSE 1 END IsHardware
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
OUTER APPLY (
	SELECT TOP 1 value_json__corrupt_record
	FROM [sourceNuudlNetCrackerView].[ibsnrmlcharacteristic_History] chr
	WHERE product_instance_id = COALESCE(i.item_json_parentId, i.id)
		AND name = 'International Phone Number'
	ORDER BY NUUDL_ID DESC
) chr
LEFT JOIN [sourceNuudlNetCrackerView].[pimnrmlproductoffering_History] po
	ON po.id = i.item_json_offeringId
LEFT JOIN [sourceNuudlNetCrackerView].[pimnrmlproductfamily_History] pf
	ON pf.id = po.product_family_id

WHERE 1=1
	-- filter out lines where we have no product offering
	AND i.item_json_offeringId IS NOT NULL
	
	--we are excluding those subscriptions because of data issues due to testing activities in production
	AND i.id NOT IN ('b5beb355-0379-41f2-aaad-47297c9548cb', '39476242-7ab7-467e-b88a-b3968a8cb7e9') 
	--AND COALESCE(i.item_json_parentId, i.id) = '8f166ff1-f4ab-4157-95ff-f94d7cd79e9d'



-- Get employees who either added or cancelled the quote
DROP TABLE IF EXISTS #quote_employees
SELECT 
	al.QuoteKey,
	MAX(created.EmployeeKey) EmployeeKey,
	MAX(cancelled.EmployeeCancelledKey) EmployeeCancelledKey
INTO #quote_employees
FROM #all_lines al
OUTER APPLY (
	SELECT TOP 1 ucreated.name AS EmployeeKey
	FROM sourceNuudlNetCrackerView.worklogitems_History qcreated
	INNER JOIN sourceNuudlNetCrackerView.orgchartteammember_History ucreated
		ON ucreated.idm_user_id = qcreated.changedby_json_userId
	WHERE qcreated.ref_id = al.item_json_quoteId
		AND qcreated.source_state IS NULL
		AND qcreated.target_state = 'IN_PROGRESS'
		AND al.CurrentState = 'PLANNED'
		AND ucreated.name IS NOT NULL
) created
OUTER APPLY (
	SELECT TOP 1 ucancelled.name AS EmployeeCancelledKey
	FROM sourceNuudlNetCrackerView.worklogitems_History qcancelled
	INNER JOIN sourceNuudlNetCrackerView.orgchartteammember_History ucancelled
		ON ucancelled.idm_user_id = qcancelled.changedby_json_userId
	WHERE qcancelled.ref_id = al.item_json_quoteId
		AND qcancelled.target_state = 'CANCELLED'
		AND al.CurrentState = 'CANCELLED'
		AND ucancelled.name IS NOT NULL
) cancelled
WHERE al.CurrentState IN ('PLANNED', 'CANCELLED')
GROUP BY al.QuoteKey

-- Prepare billing contact data for next query
DROP TABLE IF EXISTS #billing_contact_details
SELECT DISTINCT
	cm.id Householdkey,
	cma.ref_id AS customer_id,
	CONCAT( 
		ISNULL( cm.Street1, '' ), 
		';', ISNULL( cm.Street2, '' ), 
		';', ISNULL( cm.[extended_attributes_json_floor], '' ), 
		';', ISNULL( cm.[extended_attributes_json_suite], '' ) , 
		';', ISNULL( cm.Postcode, '' ), 
		';', ISNULL( cm.City, '' )
	) AddressBillingKey
INTO #billing_contact_details
FROM [sourceNuudlNetCrackerView].[cimcontactmediumassociation_History] cma
INNER JOIN [sourceNuudlNetCrackerView].[cimcontactmedium_History] cm
	ON cm.id = cma.contact_medium_id
		AND cm.is_current = 1
		AND type_of_contact_method = 'Billing contact details'
WHERE
	cma.is_current = 1

CREATE UNIQUE CLUSTERED INDEX CLIX ON #billing_contact_details (customer_id)


-- Fetch second part of data connected to items history 
-- Split in two queries due to performance
DROP TABLE IF EXISTS #all_lines_2
SELECT 
	al.*,
	COALESCE(pp.ProductParentKey, pp2.ProductParentKey) AS ProductParentKey,
	bcd.AddressBillingKey,
	bcd.Householdkey,
	ISNULL(LAG( al.ProductKey ) OVER (PARTITION BY al.SubscriptionKey, IsTLO ORDER BY al.active_from_CET),'') AS  PreviousProductKey,
	ISNULL(LAG( al.CurrentState ) OVER (PARTITION BY al.SubscriptionKey, al.ProductKey ORDER BY al.active_from_CET),'') AS  PreviousState,
	CASE 
		WHEN LAG( cpd.start_dat_CET ) OVER (PARTITION BY al.SubscriptionKey, al.ProductKey ORDER BY al.active_from_CET) IS NULL THEN cpd.start_dat_CET
	END AS RGU_StartDate,
	CASE 
		WHEN LAG( cpd.start_dat_CET ) OVER (PARTITION BY al.SubscriptionKey, al.ProductKey ORDER BY al.active_from_CET) IS NULL THEN cpd.end_dat_CET
	END AS RGU_EndDate,
	qem.EmployeeKey,
	qem.EmployeeCancelledKey,
	CAST(null as nvarchar(36)) AS ProductHardwareKey,
	CAST(null as nvarchar(50)) AS TechnologyKey
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
LEFT JOIN #quote_employees qem ON qem.QuoteKey = al.QuoteKey
WHERE 1=1
	AND OrderEventKey IS NOT NULL
	--AND SubscriptionKey = 'accc0262-efa2-4bd9-b8b4-e7ff32c0759e'
	--AND IsTLO = 1
--ORDER BY active_from_CET, IsTLO DESC


-- Updating ProductHardwareKey
UPDATE al
SET ProductHardwareKey = CASE WHEN IsTLO = 1 THEN COALESCE(ph.ProductHardwareKey, ph2.ProductHardwareKey) ELSE NULL END
-- SELECT ph.ProductHardwareKey, ph2.ProductHardwareKey, al.*
FROM #all_lines_2 al
OUTER APPLY (
	SELECT TOP 1 ProductKey AS ProductHardwareKey
	FROM #all_lines
	WHERE QuoteKey = al.QuoteKey
		AND SubscriptionKey = al.SubscriptionKey
		AND IsHardware = 1
	ORDER BY active_from_CET ASC
) ph
OUTER APPLY (
	SELECT TOP 1 ProductKey AS ProductHardwareKey
	FROM #all_lines
	WHERE active_from_CET >= al.active_from_CET
		AND CalendarKey <= al.CalendarKey
		AND ProductParentKey = al.ProductKey
		AND SubscriptionKey = al.SubscriptionKey
		AND IsHardware = 1
	ORDER BY active_from_CET DESC
) ph2
WHERE IsTLO = 1
-- AND SubscriptionKey = '7a391a92-6f6e-4a10-ac4f-ab64fd659c6b'
--	AND IsTLO = 1
--ORDER BY active_from_CET, IsTLO DESC


-- Updating TechnologyKey
UPDATE al
SET TechnologyKey = tec.TechnologyKey
--SELECT *
FROM #all_lines_2 al
OUTER APPLY (
	SELECT TOP 1 item_json_characteristics_json_value AS TechnologyKey
	FROM [sourceNuudlNetCrackerView].[ibsitemshistory_History]
	WHERE id = al.SubscriptionChildKey AND active_from_CET = al.active_from_CET AND item_json_characteristics_json_name = 'Technology'
) tec
WHERE IsHardware = 0 AND IsTLO = 1


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
-- Duplicates occur when a TLO appears several times due to changes on SLO level
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
-- Removing lines that don't follow expected flow. 
-- If an offer has been cancelled it cannot be activated, completed or disconnected.
-----------------------------------------------------------------------------------------------------------------------------
DELETE a
--SELECT *
FROM #all_lines_filtered a
WHERE 1=1
	AND OrderEventName IN ('Offer Activated', 'Offer Completed', 'Offer Disconnected')
	AND EXISTS (SELECT * FROM #all_lines_filtered WHERE SubscriptionChildKey = a.SubscriptionChildKey AND OrderEventName = 'Offer Cancelled')
	--AND SubscriptionKey = '2dbee727-5c41-4df2-a12d-aac20eebe5ce'


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
-----------------------------------------------------------------------------------------------------------------------------
-- 2. Adding artificial events that aren't based on the product instance states
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------
-- Hardware refunds
-----------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #hardware_return
SELECT 
	a.id TicketKey,
	a.ticket_category,
	a.ticket_type,
	b.id AS SubscriptionKey,
	a.status_change_date,
	a.status,
	b.type,
	c.name AS EmployeeKey,
	a.extended_attributes_json_distributionChannel AS SalesChannelKey
INTO #hardware_return
FROM [sourceNuudlNetCrackerView].[cpmnrmltroubleticket_History] a
INNER JOIN [sourceNuudlNetCrackerView].[cpmnrmltroubleticketrelatedentityref_History] b
	ON a.id = b.trouble_ticket_id
LEFT JOIN [sourceNuudlNetCrackerView].orgchartteammember_History c ON c.idm_user_id = a.created_by_user_id
WHERE 1=1
	AND a.ticket_type = 'OWNED_EQUIPMENT_RETURN'
	AND a.status IN ('CLOSED', 'REFUND_COMPLETED')
	AND b.type = 'Product'


DROP TABLE IF EXISTS #hardware_return_lines
SELECT DISTINCT
	CAST(t.status_change_date AS date) AS CalendarKey,
	LEFT( CONVERT( VARCHAR, t.status_change_date, 108 ), 8 ) AS TimeKey,
	al.ProductKey, 
	al.ProductParentKey,
	al.ProductHardwareKey,
	al.CustomerKey,
	al.SubscriptionGroup,
	al.SubscriptionKey,
	al.QuoteKey,
	e.OrderEventKey,
	e.OrderEventName,
	al.ProductType,
	al.ProductName,
	t.SalesChannelKey,
	al.BillingAccountKey,
	al.PhoneDetailKey,
	al.AddressBillingKey,
	al.HouseHoldKey,
	al.TechnologyKey,
	t.EmployeeKey,
	t.TicketKey,
	al.IsTLO,
	null active_from_CET
INTO #hardware_return_lines
FROM (
	SELECT
		al.ProductKey, 
		al.ProductParentKey,
		al.ProductHardwareKey,
		al.CustomerKey,
		al.SubscriptionGroup,
		al.SubscriptionKey,
		al.SubscriptionChildKey,
		al.QuoteKey,
		al.ProductType,
		al.ProductName,
		al.BillingAccountKey,
		al.PhoneDetailKey,
		al.AddressBillingKey,
		al.HouseHoldKey,
		al.TechnologyKey,
		al.IsTLO,
		al.active_from_CET AS ValidFrom,
		ISNULL( LEAD(al.active_from_CET,1) OVER (PARTITION BY SubscriptionKey ORDER BY al.active_from_CET) , '9999-12-31') ValidTo
	FROM #all_lines_filtered_2 al
	WHERE 1=1
		AND al.CurrentState IN ( 'COMPLETED')
		AND al.IsTLO = 1
) al
INNER JOIN #hardware_return t 
	ON (t.SubscriptionKey = al.SubscriptionKey OR t.SubscriptionKey = al.SubscriptionChildKey)
		AND t.status_change_date BETWEEN al.ValidFrom AND al.ValidTo
CROSS APPLY (
	SELECT *
	FROM dim.OrderEvent 
	WHERE 
		OrderEventName = 'Hardware Return'
) e
WHERE 1=1

-----------------------------------------------------------------------------------------------------------------------------
-- Add planned disconnected events (aka terminations)
-----------------------------------------------------------------------------------------------------------------------------

-- Get ticket data
DROP TABLE IF EXISTS #terminations
SELECT 
	IDENTITY(INT,1,1) AS ID,
	b.id AS SubscriptionKey,
	a.id TicketKey,
	ticket_type,
	a.created_by_date AS PlannedDate,
	CAST(a.extended_attributes_json_changeDate as datetime2) AS ExpectedDate,
	status_change_date,
	a.status,
	b.type,
	c.name AS EmployeeKey,
	extended_attributes_json_distributionChannel AS SalesChannelKey
INTO #terminations
FROM [sourceNuudlNetCrackerView].[cpmnrmltroubleticket_History] a
INNER JOIN [sourceNuudlNetCrackerView].[cpmnrmltroubleticketrelatedentityref_History] b
	ON a.id = b.trouble_ticket_id
LEFT JOIN [sourceNuudlNetCrackerView].orgchartteammember_History c ON c.idm_user_id = a.created_by_user_id
WHERE 
	a.ticket_type IN ('TERMINATION_REQUEST','PORT_OUT_REQUEST')
	AND b.type = 'Product'
	AND a.status not in ('ERROR')

-- If there are multiple non-cancelled tickets on the same SubscriptionKey, we only keep the first.
DELETE a
--SELECT *
FROM #terminations a
INNER JOIN 
	(
	SELECT
		ID,
		ROW_NUMBER() OVER (PARTITION BY SubscriptionKey ORDER BY PlannedDate) rn,
		a.SubscriptionKey
	FROM #terminations a
	WHERE 
		SubscriptionKey IN (
			SELECT SubscriptionKey
			FROM #terminations
			WHERE 1=1
				--AND TicketKey = 'TER-20240424-07877'
				AND status not in ('CANCELLED')
			GROUP BY SubscriptionKey
			HAVING COUNT(*)>1
		)
	) b ON b.ID = a.ID
WHERE 
	rn > 1


DROP TABLE IF EXISTS #termination_lines
SELECT DISTINCT
	CASE 
		WHEN e.OrderEventName= 'Offer Disconnected Planned' THEN CAST(t.PlannedDate AS date)
		WHEN e.OrderEventName= 'Offer Disconnected Expected' THEN CAST(t.ExpectedDate AS date)
		WHEN e.OrderEventName= 'Offer Disconnected Cancelled' THEN CAST(t.status_change_date AS date)
	END AS CalendarKey,
	CASE 
		WHEN e.OrderEventName= 'Offer Disconnected Planned' THEN LEFT( CONVERT( VARCHAR, t.PlannedDate, 108 ), 8 ) 
		WHEN e.OrderEventName= 'Offer Disconnected Expected' THEN LEFT( CONVERT( VARCHAR, t.ExpectedDate, 108 ), 8 ) 
		WHEN e.OrderEventName= 'Offer Disconnected Cancelled' THEN LEFT( CONVERT( VARCHAR, t.status_change_date, 108 ), 8 ) 
	END AS TimeKey,
	al.ProductKey, 
	al.ProductParentKey,
	al.ProductHardwareKey,
	al.CustomerKey,
	al.SubscriptionGroup,
	al.SubscriptionKey,
	'' AS QuoteKey,
	e.OrderEventKey,
	e.OrderEventName,
	al.ProductType,
	al.ProductName,
	t.SalesChannelKey,
	al.BillingAccountKey,
	al.PhoneDetailKey,
	al.AddressBillingKey,
	al.HouseHoldKey,
	al.TechnologyKey,
	t.EmployeeKey,
	t.TicketKey,
	al.IsTLO,
	null active_from_CET
INTO #termination_lines
FROM (
	SELECT
		al.ProductKey, 
		al.ProductParentKey,
		al.ProductHardwareKey,
		al.CustomerKey,
		al.SubscriptionGroup,
		al.SubscriptionKey,
		al.ProductType,
		al.ProductName,
		al.BillingAccountKey,
		al.PhoneDetailKey,
		al.AddressBillingKey,
		al.HouseHoldKey,
		al.TechnologyKey,
		al.IsTLO,
		al.active_from_CET AS ValidFrom,
		ISNULL( LEAD(al.active_from_CET,1) OVER (PARTITION BY SubscriptionKey ORDER BY al.active_from_CET) , '9999-12-31') ValidTo
	FROM #all_lines_filtered_2 al
	WHERE 1=1
		--AND SubscriptionKey = '2a1e670d-fe4e-404d-aa05-1db884cb6371'
		--AND PhoneDetailKey = '4551161601'
		AND al.CurrentState IN ( 'ACTIVE')
		AND al.IsTLO = 1
) al
INNER JOIN #terminations t ON t.SubscriptionKey = al.SubscriptionKey AND t.PlannedDate BETWEEN al.ValidFrom AND al.ValidTo
CROSS APPLY (
	SELECT *
	FROM dim.OrderEvent 
	WHERE 
		OrderEventName = 'Offer Disconnected Planned'
		OR CASE WHEN t.Status <> 'CANCELLED' THEN 'Offer Disconnected Expected' END = OrderEventName
		OR CASE WHEN t.Status = 'CANCELLED' THEN 'Offer Disconnected Cancelled' END = OrderEventName
) e
WHERE 1=1


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
	al.ProductHardwareKey,
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
	al.TechnologyKey,
	al.EmployeeKey,
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

-- Commitment lines for the TLO
DROP TABLE IF EXISTS #commitment_lines
SELECT 
	CASE 
		WHEN e.OrderEventName IN ('Offer Commitment End') THEN CAST(al.expiration_date as date)
		WHEN e.OrderEventName IN ('Offer Commitment Start','Offer Commitment Broken') THEN CAST(al.active_from_CET as date)
	END CalendarKey,
	CASE 
		WHEN e.OrderEventName IN ('Offer Commitment End')THEN LEFT( CONVERT( VARCHAR, al.expiration_date, 108 ), 8 )
		WHEN e.OrderEventName IN ('Offer Commitment Start','Offer Commitment Broken') THEN LEFT( CONVERT( VARCHAR, al.active_from_CET, 108 ), 8 )
	END AS TimeKey,
	tlo.ProductKey, 
	tlo.ProductParentKey,
	hardware.ProductHardwareKey,
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
	tlo.TechnologyKey,
	al.EmployeeKey,
	tlo.IsTLO,
	al.active_from_CET
INTO #commitment_lines
FROM #all_lines_filtered_2 al
CROSS APPLY (
	SELECT *
	FROM dim.OrderEvent 
	WHERE 1=2
		OR al.CurrentState = 'ACTIVE' AND OrderEventName = 'Offer Commitment Start'
		OR al.CurrentState = 'ACTIVE' AND OrderEventName = 'Offer Commitment End'
		OR al.CurrentState = 'DISCONNECTED' AND OrderEventName = 'Offer Commitment Broken'
) e
CROSS APPLY (
	SELECT TOP 1 ProductKey, ProductParentKey, ProductName, ProductType, TechnologyKey, IsTLO
	FROM #all_lines_filtered
	WHERE SubscriptionKey = al.SubscriptionKey 
		AND active_from_CET <= al.active_from_CET
		AND CurrentState = 'ACTIVE'
		AND IsTLO = 1 
	ORDER BY active_from_CET DESC
) tlo
CROSS APPLY (
	SELECT TOP 1 ProductKey AS ProductHardwareKey
	FROM #all_lines_filtered
	WHERE SubscriptionKey = al.SubscriptionKey 
		AND CalendarKey <= al.CalendarKey
		AND CurrentState = 'ACTIVE'
		AND IsHardware = 1 
	ORDER BY active_from_CET DESC
) hardware
WHERE 1=1
	AND al.ProductName = 'Commitment'
--	AND al.SubscriptionKey = '7a391a92-6f6e-4a10-ac4f-ab64fd659c6b'
--ORDER BY CalendarKey, TimeKey

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
	s.ProductHardwareKey,
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
	s.TechnologyKey,
	s.EmployeeKey,
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
	s.ProductHardwareKey,
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
	s.TechnologyKey,
	s.EmployeeKey,
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
	s.ProductHardwareKey,
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
	s.TechnologyKey,
	s.EmployeeKey,
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
	s.ProductHardwareKey,
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
	s.TechnologyKey,
	s.EmployeeKey,
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
	s.ProductHardwareKey,
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
	s.TechnologyKey,
	s.EmployeeKey,
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

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, QuoteKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, null TicketKey, IsTLO, 1 Quantity
		,active_from_CET
	FROM #all_lines_filtered_2
	WHERE OrderEventKey IS NOT NULL
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, QuoteKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #hardware_return_lines
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, null AS ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, QuoteKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #termination_lines
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, null AS ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, QuoteKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, null TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #migration_lines
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, null AS ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, QuoteKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, null TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #disconnect_lines_from_migrations

	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, null AS ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, QuoteKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, null TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #disconnect_lines_from_product_type_change

	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, null AS ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, QuoteKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, null TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #planned_lines_from_product_type_change
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, null AS ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, QuoteKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, null TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #change_lines
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, QuoteKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, null TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #commitment_lines
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, QuoteKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, null TicketKey, IsTLO, 1 Quantity 
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
	AND ra.OrderEventName IN ('Offer Disconnected','Offer Disconnected Cancelled','Offer Disconnected Expected','Offer Disconnected Planned','RGU Disconnected')
	AND EXISTS (
		SELECT * 
		FROM #result 
		WHERE SubscriptionKey = ra.SubscriptionKey 
			AND SubscriptionGroup = ra.SubscriptionGroup
			AND ( OrderEventName = REPLACE(ra.OrderEventName,'Disconnected','Activated') )
			AND IsTLO = ra.IsTLO
			AND active_from_CET > ra.active_from_CET
	)
	--AND ra.SubscriptionKey = '2e3e5b05-c86a-4e47-a731-eea2cab36dcf'



/*
SELECT *
FROM #all_lines_filtered
WHERE SubscriptionKey = '2a1e670d-fe4e-404d-aa05-1db884cb6371'
	AND (IsTLO=1 OR ProductType IN ('Handsets','Premium Accessories'))
ORDER By 3, 4, IsTlo DESC

SELECT *
FROM sourceNuudlNetCracker.ibsitemshistory_History
WHERE item_json_quoteId = 'be2301a1-1f89-42dd-8cd9-f7f94ba822fd'
ORDER By 3, 4, IsTlo DESC


SELECT SubscriptionKey
FROM #all_lines
WHERE 1=1
	AND ProductType IN ('Handsets','Premium Accessories')
GROUP BY SubscriptionKey
HAVING MIN(ProductKey) <> MAX(ProductKey)


SELECT *
FROM #all_lines_filtered
WHERE 1=1
	--AND SubscriptionKey = '7743fb6b-8775-4349-910b-a3ec64275a64'
--	AND IsTLO=1
	AND PhoneDetailKey='4551717273'
ORDER By 2, 3, IsTlo DESC

SELECT  *
FROM #result
WHERE SubscriptionKey = '2a1e670d-fe4e-404d-aa05-1db884cb6371'
	AND IsTLO=1
--	AND OrderEventName IN ('Offer Disconnected')
ORDER By SubscriptionGroup, 1, 2, IsTlo DESC, OrderEventKey



SELECT  *
FROM #result
WHERE phonedetailkey = '4551152144'
	AND IsTLO=1
--	AND OrderEventName IN ('Offer Disconnected')
ORDER By SubscriptionGroup, 1, 2, IsTlo DESC, OrderEventKey
--*/

-----------------------------------------------------------------------------------------------------------------------------
-- Truncate and insert into stage table
-----------------------------------------------------------------------------------------------------------------------------

TRUNCATE TABLE [stage].[Fact_OrderEvents]

INSERT INTO [stage].[Fact_OrderEvents] ([CalendarKey], [TimeKey], [ProductKey], [ProductParentKey], [ProductHardwareKey], [CustomerKey], [SubscriptionKey], [QuoteKey], [OrderEventKey], [SalesChannelKey], [BillingAccountKey], 
	[PhoneDetailKey], [AddressBillingKey], [HouseHoldKey], TechnologyKey, EmployeeKey, TicketKey, [IsTLO], [Quantity])
SELECT
	CalendarKey,
	TimeKey,
	ProductKey,
	ProductParentKey,
	ProductHardwareKey,
	CustomerKey,
	SubscriptionKey,
	QuoteKey,
	OrderEventKey,
	SalesChannelKey,
	BillingAccountKey,
	PhoneDetailKey,
	AddressBillingKey,
	HouseHoldKey,
	TechnologyKey,
	EmployeeKey, 
	TicketKey,
	IsTLO,
	Quantity
FROM #result
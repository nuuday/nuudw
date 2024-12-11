

CREATE PROCEDURE [stage].[Transform_Fact_OrderEvents]
	@JobIsIncremental BIT			
AS 


DROP TABLE IF EXISTS #Subscriptions
CREATE TABLE #Subscriptions (
	SubscriptionKey NVARCHAR(36) NOT NULL,
	SubscriptionOriginalKey NVARCHAR(36) NULL,
	IsMigratedFromLegacy bit NULL DEFAULT 0
)

CREATE UNIQUE CLUSTERED INDEX CLIX ON #Subscriptions (SubscriptionKey)

INSERT INTO #Subscriptions (SubscriptionKey, SubscriptionOriginalKey)
SELECT DISTINCT SubscriptionKey, SubscriptionOriginalKey
FROM dimView.Subscription
WHERE SubscriptionKey <> '?'
	AND DWIsDeleted <> 1
--	AND SubscriptionKey IN ('0711a0e9-d98a-6502-b7d9-2d91cadb0923')

UPDATE s
SET IsMigratedFromLegacy = 1
FROM #Subscriptions s
WHERE EXISTS (
	SELECT * FROM [sourceNuudlDawnView].[ibsitemshistory_History] i
	WHERE s.SubscriptionKey = i.id AND item_extendedAttributes LIKE '%migration_phase%'
	)

-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-- 1. Collecting core events based items history (product instance) states together with dimensional data
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #all_lines
CREATE TABLE #all_lines (
	ProductInstanceID nvarchar(50),
	SubscriptionKey nvarchar(50),
	SubscriptionOriginalKey nvarchar(50),
	IsMigratedFromLegacy bit,
	CalendarKey date,
	TimeKey time(0),
	ProductKey nvarchar(50),
	ProductType nvarchar(50),
	ProductName nvarchar(250),
	CustomerKey nvarchar(50),
	OrderEventKey nvarchar(3),
	OrderEventName nvarchar(50),
	CurrentState nvarchar(100),
	QuoteKey nvarchar(50),
	QuoteItemKey nvarchar(50),
	SalesChannelKey nvarchar(50),
	BillingAccountKey nvarchar(50),
	IsTLO bit,
	active_from_CET datetime2(0),
	expiration_date datetime2(0),
	IsHardware bit,
	TechnologyKey nvarchar(50),
	PhoneDetailKey nvarchar(50),
	[ThirdPartyStoreKey] nvarchar(50) 
)


-- Fetch first part of data connected to items history 
INSERT INTO #all_lines ([ProductInstanceID], [SubscriptionKey], [SubscriptionOriginalKey], [IsMigratedFromLegacy], [CalendarKey], [TimeKey], [ProductKey], [ProductType], [ProductName], [CustomerKey], [OrderEventKey], [OrderEventName], 
	[CurrentState], [QuoteKey], [QuoteItemKey], [SalesChannelKey], [BillingAccountKey], [IsTLO], [active_from_CET], [expiration_date], [IsHardware], [TechnologyKey], [PhoneDetailKey], [ThirdPartyStoreKey])
SELECT 
	i.id ProductInstanceID,
	sub.SubscriptionKey,
	sub.SubscriptionOriginalKey,
	sub.IsMigratedFromLegacy,
	CAST(i.active_from_CET AS Date) AS CalendarKey,
	LEFT( CONVERT( VARCHAR, CAST(i.active_from_CET AS datetime2(0)), 108 ), 8 ) AS TimeKey,
	i.item_offeringId AS ProductKey,		
	CASE
		WHEN i.item_productFamilyName = 'Mobile Voice Offline' THEN 'Mobile Voice'
		WHEN i.item_productFamilyName = 'Mobile Broadband Offline' THEN 'Mobile Broadband'
		ELSE i.item_productFamilyName
	END AS ProductType,
	i.item_offeringName AS ProductName,
	--i.item_customerId AS CustomerKey,
	COALESCE(i.item_customerId, npi.customer_id) AS CustomerKey,
	ev.OrderEventKey,
	ev.OrderEventName,
	i.state CurrentState,
	--i.item_quoteId AS QuoteKey,
	COALESCE(i.item_quoteId, npi.quote_id) AS QuoteKey,
	i.id AS QuoteItemKey,
	i.item_distributionChannelId AS SalesChannelKey,
	acc.account_num AS BillingAccountKey,
	CASE WHEN i.item_parentId IS NULL THEN 1 ELSE 0 END IsTLO,
	i.active_from_CET,
	i.item_expirationDate_CET AS expiration_date,
	CASE WHEN po.extended_parameters_json_deviceType IS NULL THEN 0 ELSE 1 END IsHardware,
	cha.technology AS TechnologyKey,
	cha.phone_number AS PhoneDetailKey,
	JSON_VALUE(quote.extended_parameters, '$."3rdPartyStoreId"[0]') ThirdPartyStoreKey
FROM [sourceNuudlDawnView].[ibsitemshistory_History] i
LEFT JOIN [sourceNuudlDawnView].[ibsnrmlproductinstance_History] npi
    ON npi.id = i.id AND npi.NUUDL_IsLatest = 1
INNER JOIN #Subscriptions sub 
	ON sub.SubscriptionKey = COALESCE(i.item_parentId, i.id)
LEFT JOIN sourceNuudlDawnView.[ibsitemshistorycharacteristics_History] cha ON cha.NUUDL_ID = i.NUUDL_ID
INNER JOIN dim.OrderEvent ev 
	ON ev.SourceEventName = i.[state]
LEFT JOIN [sourceNuudlDawnView].[qssnrmlquote_History] quote
	ON quote.id = i.item_quoteId 
		AND quote.NUUDL_IsLatest =1
LEFT JOIN [sourceNuudlDawnView].[nrmaccountkeyname_History] acc
	ON acc.name = JSON_VALUE(i.item_accountRef,'$[0].refId') 
		AND acc.NUUDL_IsLatest =1
LEFT JOIN [sourceNuudlNetCrackerView].[pimnrmlproductoffering_History] po
	ON po.id = i.item_offeringId
WHERE 1=1
	AND i.NUUDL_IsLatest = 1
--	AND COALESCE(i.item_parentId, i.id) = '22654a4a-7078-45a2-a356-9064d7db6e76'


CREATE CLUSTERED INDEX CLIX ON #all_lines (SubscriptionOriginalKey, QuoteKey, IsTLO, active_from_CET)	
CREATE NONCLUSTERED INDEX NLIX ON #all_lines (CurrentState, ProductInstanceID, ProductKey) INCLUDE (IsTLO, SubscriptionOriginalKey, active_from_cet, ProductType, ProductName, CustomerKey, QuoteKey, QuoteItemKey, SalesChannelKey, BillingAccountKey, TechnologyKey, PhoneDetailKey)


/* 
	We have seen examples on CANCELLED items which have no information in item column. 
	In these cases we fetch data from the previous PLANNED row.
*/
UPDATE al
SET 
	al.ProductKey = COALESCE(al.ProductKey, p.ProductKey)
	, al.SubscriptionKey = p.SubscriptionKey
	, al.SubscriptionOriginalKey = p.SubscriptionOriginalKey
	, al.IsTLO = p.IsTLO
	, al.ProductType = COALESCE(al.ProductType, p.ProductType)
	, al.ProductName = COALESCE(al.ProductName, p.ProductName)
	, al.CustomerKey = COALESCE(al.CustomerKey, p.CustomerKey)
	, al.QuoteKey = COALESCE(al.QuoteKey, p.QuoteKey)
	, al.QuoteItemKey = COALESCE(al.QuoteItemKey, p.QuoteItemKey)
	, al.SalesChannelKey = COALESCE(al.SalesChannelKey, p.SalesChannelKey)
	, al.BillingAccountKey = COALESCE(al.BillingAccountKey, p.BillingAccountKey)
	, al.TechnologyKey = COALESCE(al.TechnologyKey, p.TechnologyKey)	
	, al.PhoneDetailKey = COALESCE(al.PhoneDetailKey, p.PhoneDetailKey)
	, al.ThirdPartyStoreKey = COALESCE(al.ThirdPartyStoreKey, p.ThirdPartyStoreKey)
--SELECT p.*
FROM #all_lines al
CROSS APPLY (
	SELECT TOP 1 *
	FROM #all_lines
	WHERE CurrentState = 'PLANNED'
		AND ProductInstanceID = al.ProductInstanceID
		AND active_from_cet <= al.active_from_cet
	ORDER BY active_from_cet DESC
) p
WHERE al.CurrentState='Cancelled' AND al.ProductKey IS NULL


-- Removing all lines where OrderEventKey or ProductKey is null
DELETE FROM #all_lines 
WHERE 
	ProductKey IS NULL


-- Fetch worklog items for next step
DROP TABLE IF EXISTS #worklog_quotes
SELECT 
	u.name AS EmployeeKey
	, w.ref_id AS QuoteKey
	, w.source_state
	, w.target_state	
INTO #worklog_quotes
FROM [sourceNuudlDawnView].worklogitems_History w
INNER JOIN [sourceNuudlDawnView].orgchrteammember_History u
	ON u.idm_user_id = w.changedBy_userId
		AND u.name IS NOT NULL
		AND u.NUUDL_IsLatest = 1
WHERE w.NUUDL_IsLatest = 1
	AND w.ref_type = 'Quote'

CREATE CLUSTERED INDEX CLIX ON #worklog_quotes (QuoteKey)	

-- Get employees who either added or cancelled the quote
DROP TABLE IF EXISTS #quote_employees
SELECT 
	al.QuoteKey,
	MAX(created.EmployeeKey) EmployeeKey,
	MAX(cancelled.EmployeeCancelledKey) EmployeeCancelledKey
INTO #quote_employees
FROM #all_lines al
OUTER APPLY (
	SELECT TOP 1 wq.EmployeeKey
	FROM #worklog_quotes wq
	WHERE wq.QuoteKey = al.QuoteKey
		AND wq.source_state IS NULL
		AND wq.target_state = 'IN_PROGRESS'
		AND al.CurrentState = 'PLANNED'
) created
OUTER APPLY (
	SELECT TOP 1 wq.EmployeeKey AS EmployeeCancelledKey
	FROM #worklog_quotes wq
	WHERE wq.QuoteKey = al.QuoteKey
		AND wq.target_state = 'CANCELLED'
		AND al.CurrentState = 'CANCELLED'
) cancelled
WHERE al.CurrentState IN ('PLANNED', 'CANCELLED')
GROUP BY al.QuoteKey


-- Prepare billing contact data for next query
DROP TABLE IF EXISTS #billing_contact_details
SELECT DISTINCT
	cm.id Householdkey,
	cma.ref_id AS CustomerKey,
	CONCAT( 
		ISNULL( cm.Street1, '' ), 
		';', ISNULL( cm.Street2, '' ), 
		';', ISNULL( cm.[extended_attributes_floor], '' ), 
		';', ISNULL( cm.[extended_attributes_suite], '' ) , 
		';', ISNULL( cm.Postcode, '' ), 
		';', ISNULL( cm.City, '' )
	) AddressBillingKey
	,ROW_NUMBER() OVER( PARTITION BY cma.ref_id order by cm.type_of_contact) as rownumber
INTO #billing_contact_details
FROM [sourceNuudlDawnView].[cimcontactmediumassociation_History] cma
INNER JOIN [sourceNuudlDawnView].[cimcontactmedium_History] cm
	ON cm.id = cma.contact_medium_id
		AND cm.NUUDL_IsLatest =1
		AND type_of_contact_method = 'Billing contact details'
WHERE
	cma.NUUDL_IsLatest =1
	--AND cma.ref_id='2ca8abb7-2e80-429e-be0a-65c594667a05'
--delete multiple address detail for customer
delete from #billing_contact_details where rownumber>1

CREATE UNIQUE CLUSTERED INDEX CLIX ON #billing_contact_details (CustomerKey)


-- Fetch second part of data connected to items history 
-- Split in two queries due to performance
DROP TABLE IF EXISTS #all_lines_2
SELECT 
	al.*,
	COALESCE(pp.ProductParentKey, pp2.ProductParentKey) AS ProductParentKey,
	bcd.AddressBillingKey,
	bcd.Householdkey,
	ISNULL(LAG( al.ProductKey ) OVER (PARTITION BY al.SubscriptionOriginalKey, IsTLO ORDER BY al.active_from_CET,al.Ordereventkey,al.ProductInstanceID),'') AS  PreviousProductKey,
	ISNULL(LAG( al.CurrentState ) OVER (PARTITION BY al.SubscriptionOriginalKey, al.ProductKey ORDER BY al.active_from_CET,al.Ordereventkey,al.ProductInstanceID),'') AS  PreviousState,
	CASE 
		WHEN LAG( cpd.start_dat_CET ) OVER (PARTITION BY al.SubscriptionOriginalKey, al.ProductKey ORDER BY al.active_from_CET) IS NULL THEN cpd.start_dat_CET
	END AS RGU_StartDate,
	CASE 
		WHEN LAG( cpd.start_dat_CET ) OVER (PARTITION BY al.SubscriptionOriginalKey, al.ProductKey ORDER BY al.active_from_CET) IS NULL THEN cpd.end_dat_CET
	END AS RGU_EndDate,
	qem.EmployeeKey,
	qem.EmployeeCancelledKey,
	CAST(null as nvarchar(36)) AS ProductHardwareKey
INTO #all_lines_2
FROM #all_lines al
OUTER APPLY (
	SELECT TOP 1 ProductKey AS ProductParentKey
	FROM #all_lines
	WHERE QuoteKey = al.QuoteKey
		AND SubscriptionOriginalKey = al.SubscriptionOriginalKey
		AND IsTLO = 1
	ORDER BY active_from_CET DESC
) pp
OUTER APPLY (
	SELECT TOP 1 ProductKey AS ProductParentKey
	FROM #all_lines
	WHERE active_from_CET <= al.active_from_CET
		AND SubscriptionOriginalKey = al.SubscriptionOriginalKey
		AND IsTLO = 1
	ORDER BY active_from_CET DESC
) pp2
LEFT JOIN #billing_contact_details bcd
	ON bcd.CustomerKey = al.CustomerKey
LEFT JOIN [sourceNuudlDawnView].[nrmcusthasproductkeyname_History] kn
	ON kn.name = al.SubscriptionKey
		AND kn.NUUDL_IsLatest =1
LEFT JOIN [sourceNuudlDawnView].[nrmcustproductdetails_History] cpd
	ON cpd.product_seq = kn.product_seq
		AND cpd.customer_ref = kn.customer_ref
		AND cpd.NUUDL_IsLatest =1
		AND (cpd.product_label = al.ProductName OR cpd.override_product_name = al.ProductName)
		AND al.active_from_CET BETWEEN cpd.start_dat AND ISNULL(cpd.end_dat,'9999-12-31')
LEFT JOIN #quote_employees qem ON qem.QuoteKey = al.QuoteKey
WHERE 1=1
	--AND SubscriptionKey = 'bec4e1a1-dfd7-4764-bc03-1a88631fca05'
	--AND IsTLO = 1
--ORDER BY active_from_CET, IsTLO DESC


CREATE CLUSTERED INDEX CLIX ON #all_lines_2 (SubscriptionKey, QuoteKey, IsTLO, active_from_CET)	


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
	ORDER BY active_from_CET ASC, IsTLO
) ph
OUTER APPLY (
	SELECT TOP 1 ProductKey AS ProductHardwareKey
	FROM #all_lines_2
	WHERE active_from_CET >= al.active_from_CET
		AND CalendarKey <= al.CalendarKey
		AND ProductParentKey = al.ProductKey
		AND SubscriptionKey = al.SubscriptionKey
		AND IsHardware = 1
	ORDER BY active_from_CET DESC, IsTLO
) ph2
WHERE IsTLO = 1
-- AND SubscriptionKey = '7a391a92-6f6e-4a10-ac4f-ab64fd659c6b'
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
	AND EXISTS (SELECT * FROM #all_lines_filtered WHERE ProductInstanceID = a.ProductInstanceID AND OrderEventName = 'Offer Cancelled')
	--AND SubscriptionKey = '2dbee727-5c41-4df2-a12d-aac20eebe5ce'


-----------------------------------------------------------------------------------------------------------------------------
-- We divide the Subscription into groups when the Product Type is changed on the TLO
-- Each grouping is considered as its own subscription when rules are applied
-----------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #all_lines_filtered_2
SELECT 
	SUM(ProductTypeChangeFlag) OVER (PARTITION BY SubscriptionOriginalKey ORDER BY active_from_CET) AS SubscriptionGroup,
	*
INTO #all_lines_filtered_2
FROM (
	SELECT 
		CASE 
			WHEN IsTLO = 1 AND ProductType <> LAG( ProductType ) OVER (PARTITION BY al.SubscriptionOriginalKey, IsTLO ORDER BY active_from_CET) THEN 1
			--WHEN IsTLO = 1 THEN 0
			ELSE 0
		END AS ProductTypeChangeFlag,
		*
	FROM #all_lines_filtered al
	WHERE 1=1
		--AND IsTLO = 1
		--AND SubscriptionOriginalKey ='b5f00442-6c45-4c82-93fe-b5394ee207ee'
) q
--ORDER BY active_from_CET, IsTLO DESC


CREATE CLUSTERED INDEX CLIX ON #all_lines_filtered_2 (SubscriptionKey, CurrentState, active_from_CET)


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
	a.status_change_date_CET AS status_change_date,
	a.status,
	b.type,
	c.name AS EmployeeKey,
	JSON_VALUE(a.extended_attributes,'$.distributionChannel') AS SalesChannelKey
INTO #hardware_return
FROM [sourceNuudlDawnView].[cpmnrmltroubleticket_History] a
INNER JOIN [sourceNuudlDawnView].[cpmnrmltroubleticketrelatedentityref_History] b
	ON a.id = b.trouble_ticket_id
		AND b.NUUDL_IsLatest =1
LEFT JOIN [sourceNuudlDawnView].orgchrteammember_History c 
	ON c.idm_user_id = a.created_by_user_id
		AND c.NUUDL_IsLatest =1
WHERE 1=1
	AND a.NUUDL_IsCurrent =1
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
	al.SubscriptionOriginalKey,
	al.QuoteKey,
	al.QuoteItemKey,
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
	al.ThirdPartyStoreKey,
	al.IsTLO,
	CAST(t.status_change_date as datetime2(0)) active_from_CET
INTO #hardware_return_lines
FROM (
	SELECT
		al.ProductKey, 
		al.ProductParentKey,
		al.ProductHardwareKey,
		al.CustomerKey,
		al.SubscriptionGroup,
		al.SubscriptionKey,
		al.SubscriptionOriginalKey,
		al.ProductInstanceID,
		al.QuoteKey,
		al.QuoteItemKey,
		al.ProductType,
		al.ProductName,
		al.BillingAccountKey,
		al.PhoneDetailKey,
		al.AddressBillingKey,
		al.HouseHoldKey,
		al.TechnologyKey,
		al.ThirdPartyStoreKey,
		al.IsTLO,
		al.active_from_CET AS ValidFrom,
		ISNULL( LEAD(al.active_from_CET,1) OVER (PARTITION BY SubscriptionOriginalKey ORDER BY al.active_from_CET) , '9999-12-31') ValidTo
	FROM #all_lines_filtered_2 al
	WHERE 1=1
		AND al.CurrentState IN ( 'COMPLETED')
		AND al.IsTLO = 1
) al
INNER JOIN #hardware_return t 
	ON (t.SubscriptionKey = al.SubscriptionKey OR t.SubscriptionKey = al.ProductInstanceID)
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
	a.created_by_date_CET AS PlannedDate,
	CAST(extended_attributes_changeDate_CET as datetime2(0)) AS ExpectedDate,
	status_change_date_CET AS status_change_date,
	a.status,
	b.type,
	c.name AS EmployeeKey,
	JSON_VALUE(extended_attributes, '$.distributionChannel') AS SalesChannelKey
INTO #terminations
FROM [sourceNuudlDawnView].[cpmnrmltroubleticket_History] a
INNER JOIN [sourceNuudlDawnView].[cpmnrmltroubleticketrelatedentityref_History] b
	ON a.id = b.trouble_ticket_id
		AND b.NUUDL_IsLatest =1
LEFT JOIN [sourceNuudlDawnView].orgchrteammember_History c 
	ON c.idm_user_id = a.created_by_user_id
		AND c.NUUDL_IsLatest =1
WHERE 1=1
	AND a.NUUDL_IsCurrent =1
	AND a.ticket_type IN ('TERMINATION_REQUEST','PORT_OUT_REQUEST')
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
	al.SubscriptionOriginalKey,
	al.QuoteKey,
	al.QuoteItemKey,
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
	al.ThirdPartyStoreKey,
	al.IsTLO,
	CASE 
		WHEN e.OrderEventName= 'Offer Disconnected Planned' THEN CAST(t.PlannedDate AS DATETIME)
		WHEN e.OrderEventName= 'Offer Disconnected Expected' THEN CAST(t.ExpectedDate AS DATETIME)
		WHEN e.OrderEventName= 'Offer Disconnected Cancelled' THEN CAST(t.status_change_date AS DATETIME)
	END active_from_CET
INTO #termination_lines
FROM (
	SELECT
		al.ProductKey, 
		al.ProductParentKey,
		al.ProductHardwareKey,
		al.CustomerKey,
		al.SubscriptionGroup,
		al.SubscriptionKey,	
		al.SubscriptionOriginalKey,
		al.QuoteKey,
		al.QuoteItemKey,
		al.ProductType,
		al.ProductName,
		al.BillingAccountKey,
		al.PhoneDetailKey,
		al.AddressBillingKey,
		al.HouseHoldKey,
		al.TechnologyKey,
		al.ThirdPartyStoreKey,
		al.IsTLO,
		al.active_from_CET AS ValidFrom,
		ISNULL( LEAD(al.active_from_CET,1) OVER (PARTITION BY SubscriptionOriginalKey ORDER BY al.active_from_CET) , '9999-12-31') ValidTo
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
-- Add Future sales tickets and future Migrations
-----------------------------------------------------------------------------------------------------------------------------


DROP TABLE IF EXISTS #future_migrations
SELECT 
	IDENTITY(INT,1,1) AS ID,
	b.id AS SubscriptionKey,
	a.id TicketKey,
	a.ticket_category,
	ticket_type,
	a.created_by_date_CET AS PlannedDate,
	CAST(extended_attributes_changeDate_CET as datetime2(0)) AS ExpectedDate,
	status_change_date_CET AS status_change_date,
	a.status,
	b.type,
	c.name AS EmployeeKey,
	JSON_VALUE(extended_attributes, '$.distributionChannel') AS SalesChannelKey,
	--qa.quote_id ,qa.creation_time, 
	po.name as ProductName, 
	po.id as ProductKey,
	CASE
		WHEN pf.name = 'Mobile Voice Offline' THEN 'Mobile Voice'
		WHEN pf.name = 'Mobile Broadband Offline' THEN 'Mobile Broadband'
		ELSE pf.name
	END AS ProductType
	
INTO #future_migrations
FROM [sourceNuudlDawnView].[cpmnrmltroubleticket_History] a
INNER JOIN [sourceNuudlDawnView].[cpmnrmltroubleticketrelatedentityref_History] b
	ON a.id = b.trouble_ticket_id
		AND b.NUUDL_IsLatest = 1
LEFT JOIN [sourceNuudlDawnView].orgchrteammember_History c 
	ON c.idm_user_id = a.created_by_user_id
		AND c.NUUDL_IsLatest = 1
LEFT JOIN [sourceNuudlNetCrackerView].[pimnrmlproductoffering_History] po 
	ON  po.name=b.name
LEFT JOIN  [sourceNuudlNetCracker].[pimnrmlproductfamily]  pf 
	ON po.product_family_id = pf.id 
WHERE 1=1
	AND a.NUUDL_IsLatest =1
	AND a.ticket_type IN ('FUTURE_DATE_CHANGE')
	AND b.type = 'Product'
	AND a.status not in ('ERROR')
	
	
-- If there are multiple non-cancelled tickets on the same SubscriptionKey, we only keep the first.
DELETE a
--SELECT *
FROM #future_migrations a
INNER JOIN 
	(
	SELECT
		ID,
		ROW_NUMBER() OVER (PARTITION BY SubscriptionKey ORDER BY PlannedDate) rn,
		a.SubscriptionKey
	FROM #future_migrations a
	WHERE 
		SubscriptionKey IN (
			SELECT SubscriptionKey
			FROM #future_migrations
			WHERE 1=1
				--AND TicketKey = 'TER-20240424-07877'
				AND status not in ('CANCELLED')
			GROUP BY SubscriptionKey
			HAVING COUNT(*)>1
		)
	) b ON b.ID = a.ID
WHERE 
	rn > 1
	

DROP TABLE IF EXISTS #future_migrations_lines 

/****** Insert order events rows for future product ******/
SELECT DISTINCT
	CASE 
		WHEN e.OrderEventName= 'Offer Planned' THEN CAST(t.PlannedDate AS date)
		WHEN e.OrderEventName ='Offer Activated Expected' THEN CAST(t.ExpectedDate AS date)
		WHEN e.OrderEventName = 'Migration To Planned' THEN CAST(t.PlannedDate AS date)
		WHEN e.OrderEventName= 'Offer Cancelled' THEN CAST(t.status_change_date AS date)
	END AS CalendarKey,
	CASE 
		WHEN e.OrderEventName= 'Offer Planned' THEN LEFT( CONVERT( VARCHAR, t.PlannedDate, 108 ), 8 ) 
		WHEN e.OrderEventName ='Offer Activated Expected' THEN LEFT( CONVERT( VARCHAR, t.ExpectedDate, 108 ), 8 )
		WHEN e.OrderEventName= 'Migration To Planned' THEN LEFT( CONVERT( VARCHAR, t.PlannedDate, 108 ), 8 ) 
		WHEN e.OrderEventName= 'Offer Cancelled' THEN LEFT( CONVERT( VARCHAR, t.status_change_date, 108 ), 8 ) 
	END AS TimeKey,
	t.ProductKey, 
	t.ProductKey as ProductParentKey,
	al.ProductHardwareKey,
	al.CustomerKey,
	al.SubscriptionGroup,
	al.SubscriptionKey,
	al.SubscriptionOriginalKey,
	al.QuoteKey,
	al.QuoteItemKey,
	e.OrderEventKey,
	e.OrderEventName,
	t.ProductType,
	t.ProductName, 
	t.SalesChannelKey,
	al.BillingAccountKey,
	al.PhoneDetailKey,
	al.AddressBillingKey,
	al.HouseHoldKey,
	al.TechnologyKey,
	t.EmployeeKey,
	t.TicketKey,
	al.ThirdPartyStoreKey,
	al.IsTLO,
	CASE 
		WHEN e.OrderEventName= 'Offer Planned' THEN CAST(t.PlannedDate AS date)
		WHEN e.OrderEventName ='Offer Activated Expected' THEN CAST(t.ExpectedDate AS date)
		WHEN e.OrderEventName = 'Migration To Planned' THEN CAST(t.PlannedDate AS date)
		WHEN e.OrderEventName= 'Offer Cancelled' THEN CAST(t.status_change_date AS date)
	END active_from_CET,
	CASE 
		WHEN  t.ProductType= al.ProductType and e.OrderEventName= 'Migration To Planned' THEN 1
		WHEN  t.ProductType= al.ProductType and e.OrderEventName <> 'Migration To Planned' THEN 0
		ELSE 1 END as Quantity
	
INTO #future_migrations_lines
FROM (
	SELECT
		al.ProductKey, 
		al.ProductParentKey,
		al.ProductHardwareKey,
		al.CustomerKey,
		al.SubscriptionGroup,
		al.SubscriptionKey,	
		al.SubscriptionOriginalKey,
		al.QuoteKey,
		al.QuoteItemKey,
		al.ProductType,
		al.ProductName,
		al.BillingAccountKey,
		al.PhoneDetailKey,
		al.AddressBillingKey,
		al.HouseHoldKey,
		al.TechnologyKey,
		al.ThirdPartyStoreKey,
		al.IsTLO,
		al.active_from_CET AS ValidFrom,
		ISNULL( LEAD(al.active_from_CET,1) OVER (PARTITION BY SubscriptionOriginalKey ORDER BY al.active_from_CET) , '9999-12-31') ValidTo
		
	FROM #all_lines_filtered_2 al
	WHERE 1=1
		AND al.CurrentState IN ( 'ACTIVE')
		AND al.IsTLO = 1
) al
INNER JOIN #future_migrations t ON t.SubscriptionKey = al.SubscriptionKey AND t.PlannedDate BETWEEN al.ValidFrom AND al.ValidTo
CROSS APPLY (
	SELECT *
	FROM dim.OrderEvent 
	WHERE 
		OrderEventName = 'Offer Planned'
		OR CASE WHEN t.Status <> 'CANCELLED' THEN 'Offer Activated Expected' END = OrderEventName
		OR CASE WHEN t.Status <> 'CANCELLED' and t.ProductType= al.ProductType THEN 'Migration To Planned' END = OrderEventName
		OR CASE WHEN t.Status = 'CANCELLED' THEN 'Offer Cancelled' END = OrderEventName
) e
WHERE 1=1  


/***** INSERT  order events rows for current product *****/

INSERT INTO #future_migrations_lines
SELECT DISTINCT
	CASE 
		WHEN e.OrderEventName= 'Offer Disconnected Planned' THEN CAST(t.PlannedDate AS date)
		WHEN e.OrderEventName= 'Offer Disconnected Expected' THEN CAST(t.ExpectedDate AS date)
		WHEN e.OrderEventName= 'Migration From Planned' THEN CAST(t.PlannedDate AS date)
		WHEN e.OrderEventName= 'Offer Disconnected Cancelled' THEN CAST(t.status_change_date AS date)
	END AS CalendarKey,
	CASE 
		WHEN e.OrderEventName= 'Offer Disconnected Planned' THEN LEFT( CONVERT( VARCHAR, t.PlannedDate, 108 ), 8 ) 
		WHEN e.OrderEventName= 'Offer Disconnected Expected' THEN LEFT( CONVERT( VARCHAR, t.ExpectedDate, 108 ), 8 ) 
		WHEN e.OrderEventName= 'Migration From Planned' THEN LEFT( CONVERT( VARCHAR, t.PlannedDate, 108 ), 8 )
		WHEN e.OrderEventName= 'Offer Disconnected Cancelled' THEN LEFT( CONVERT( VARCHAR, t.status_change_date, 108 ), 8 ) 
	END AS TimeKey,
	al.ProductKey, 
	al.ProductKey as ProductParentKey,
	al.ProductHardwareKey,
	al.CustomerKey,
	al.SubscriptionGroup,
	al.SubscriptionKey,
	al.SubscriptionOriginalKey,
	al.QuoteKey,
	al.QuoteItemKey,
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
	al.ThirdPartyStoreKey,
	al.IsTLO,
	CASE 
		WHEN e.OrderEventName= 'Offer Disconnected Planned' THEN CAST(t.PlannedDate AS date)
		WHEN e.OrderEventName= 'Offer Disconnected Expected' THEN CAST(t.ExpectedDate AS date)
		WHEN e.OrderEventName= 'Migration From Planned' THEN CAST(t.PlannedDate AS date)
		WHEN e.OrderEventName= 'Offer Disconnected Cancelled' THEN CAST(t.status_change_date AS date)
	END active_from_CET,
	CASE 
		WHEN  t.ProductType= al.ProductType and e.OrderEventName= 'Migration From Planned' THEN 1
		WHEN  t.ProductType= al.ProductType and e.OrderEventName <> 'Migration From Planned' THEN 0
		ELSE 1 END as Quantity
FROM (
	SELECT
		al.ProductKey, 
		al.ProductParentKey,
		al.ProductHardwareKey,
		al.CustomerKey,
		al.SubscriptionGroup,
		al.SubscriptionKey,	
		al.SubscriptionOriginalKey,
		al.QuoteKey,
		al.QuoteItemKey,
		al.ProductType,
		al.ProductName,
		al.BillingAccountKey,
		al.PhoneDetailKey,
		al.AddressBillingKey,
		al.HouseHoldKey,
		al.TechnologyKey,
		al.ThirdPartyStoreKey,
		al.IsTLO,
		al.active_from_CET AS ValidFrom,
		ISNULL( LEAD(al.active_from_CET,1) OVER (PARTITION BY SubscriptionOriginalKey ORDER BY al.active_from_CET) , '9999-12-31') ValidTo
	FROM #all_lines_filtered_2 al
	WHERE 1=1
		AND al.CurrentState IN ( 'ACTIVE')
		AND al.IsTLO = 1
) al
INNER JOIN #future_migrations t ON t.SubscriptionKey = al.SubscriptionKey AND t.PlannedDate BETWEEN al.ValidFrom AND al.ValidTo
CROSS APPLY (
	SELECT *
	FROM dim.OrderEvent 
	WHERE 
		OrderEventName = 'Offer Disconnected Planned'
		OR CASE WHEN t.Status <> 'CANCELLED' THEN 'Offer Disconnected Expected' END = OrderEventName
		OR CASE WHEN t.Status <> 'CANCELLED' and t.ProductType= al.ProductType THEN 'Migration From Planned' END = OrderEventName
		OR CASE WHEN t.Status = 'CANCELLED' THEN 'Offer Disconnected Cancelled' END = OrderEventName
) e
WHERE 1=1  
/*
select count(distinct producttype) , subscriptionkey from #future_migrations_lines 
group by subscriptionkey
having count(distinct producttype)>1


select * from #future_migrations_lines  --where  subscriptionkey= '09ec9981-c868-4cbb-ad85-bd0e1df647b1'
order by 8,1,2
*/

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
	al.SubscriptionOriginalKey,
	al.QuoteKey,
	al.QuoteItemKey,
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
	al.ThirdPartyStoreKey,
	al.IsTLO,
	CASE e.OrderEventName
		WHEN 'RGU Activated' THEN RGU_StartDate
		WHEN 'RGU Disconnected' THEN RGU_EndDate
	END active_from_CET
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
	al.SubscriptionOriginalKey,
	al.QuoteKey,
	al.QuoteItemKey,
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
	al.ThirdPartyStoreKey,
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
	FROM #all_lines_filtered_2
	WHERE SubscriptionKey = al.SubscriptionKey 
		AND active_from_CET <= al.active_from_CET
		AND CurrentState = 'ACTIVE'
		AND IsTLO = 1 
	ORDER BY active_from_CET DESC
) tlo
OUTER APPLY (
	SELECT TOP 1 ProductKey AS ProductHardwareKey
	FROM #all_lines_filtered_2
	WHERE SubscriptionKey = al.SubscriptionKey 
		AND CalendarKey <= al.CalendarKey
		AND CurrentState IN ('COMPLETED', 'ACTIVE')
		AND IsHardware = 1 
	ORDER BY active_from_CET DESC
) hardware
WHERE 1=1
	AND al.ProductName = 'Commitment'
--	AND hardware.ProductHardwareKey IS NULL
--	AND al.SubscriptionKey = '7a391a92-6f6e-4a10-ac4f-ab64fd659c6b'
--ORDER BY CalendarKey, TimeKey


-----------------------------------------------------------------------------------------------------------------------------
-- Add events do to change in product type and product
-----------------------------------------------------------------------------------------------------------------------------

-- Get all active lines
DROP TABLE IF EXISTS #active_lines
SELECT al.* 
	, LAG( al.ProductType ) OVER (PARTITION BY al.SubscriptionOriginalKey, al.IsTLO ORDER BY al.active_from_CET) PreviousProductType
	, LEAD( al.ProductType ) OVER (PARTITION BY al.SubscriptionOriginalKey, al.IsTLO ORDER BY al.active_from_CET) NextProductType
	, LAG( al.ProductName ) OVER (PARTITION BY al.SubscriptionGroup, al.SubscriptionKey, al.ProductType ORDER BY al.active_from_CET) PreviousProductName
	, LEAD( al.ProductName ) OVER (PARTITION BY al.SubscriptionGroup, al.SubscriptionKey, al.ProductType ORDER BY al.active_from_CET) NextProductName
	, LAG( al.active_from_CET ) OVER (PARTITION BY al.SubscriptionGroup, al.SubscriptionKey, al.ProductType ORDER BY al.active_from_CET) Previous_active_from_CET
	, LEAD( al.active_from_CET ) OVER (PARTITION BY al.SubscriptionGroup, al.SubscriptionKey, al.ProductType ORDER BY al.active_from_CET) Next_active_from_CET
	, LEAD( al.ProductKey ) OVER (PARTITION BY al.SubscriptionGroup, al.SubscriptionKey, al.ProductType ORDER BY al.active_from_CET) NextProductKey
	, LEAD( al.CalendarKey ) OVER (PARTITION BY al.SubscriptionGroup, al.SubscriptionKey, al.ProductType ORDER BY al.active_from_CET) NextDate
	, LEAD( al.TimeKey ) OVER (PARTITION BY al.SubscriptionGroup, al.SubscriptionKey, al.ProductType ORDER BY al.active_from_CET) NextTime
	, LEAD( al.CalendarKey ) OVER (PARTITION BY al.SubscriptionOriginalKey, al.IsTLO ORDER BY al.active_from_CET) NextDateTLO
	, LEAD( al.TimeKey ) OVER (PARTITION BY al.SubscriptionOriginalKey, al.IsTLO ORDER BY al.active_from_CET) NextTimeTLO
INTO #active_lines
FROM #all_lines_filtered_2 al
WHERE al.CurrentState = 'ACTIVE'



-- Create Migration Legacy lines
DROP TABLE IF EXISTS #migration_legacy_lines
SELECT 
	s.CalendarKey,
	s.TimeKey,
	s.ProductKey, 
	s.ProductParentKey,
	s.ProductHardwareKey,
	s.CustomerKey,
	s.SubscriptionGroup,
	s.SubscriptionKey,
	s.SubscriptionOriginalKey,
	s.QuoteKey,
	s.QuoteItemKey,
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
	s.ThirdPartyStoreKey,
	s.IsTLO,
	s.active_from_CET
INTO #migration_legacy_lines
FROM #active_lines s
CROSS APPLY (
	SELECT *
	FROM dim.OrderEvent 
	WHERE OrderEventName = 'Migration Legacy'
) e
CROSS APPLY (
	SELECT MIN(active_from_cet) FirstActivatedDate
	FROM #active_lines
	WHERE SubscriptionOriginalKey = s.SubscriptionOriginalKey
		AND IsMigratedFromLegacy = 1
) f
WHERE s.active_from_cet = f.FirstActivatedDate


DROP TABLE IF EXISTS #migration_lines_with_prices
SELECT 
	new.*,
	old.*,
	s.*
INTO #migration_lines_with_prices
FROM #active_lines s
OUTER APPLY (
	SELECT 
		MAX(CASE WHEN ps.name = 'Monthly Fee' THEN pci.amount ELSE null END) OldMonthlyFee,
		MAX(CASE WHEN ps.name = 'Activation Fee' THEN pci.amount ELSE null END) OldActivationFee
	FROM sourceNuudlNetCrackerView.pimnrmlproductofferingpricechargekey_History pck
	INNER JOIN sourceNuudlNetCrackerView.pimnrmlproductofferingpricechargeitem_History pci
		ON pci.price_key_id = pck.id
			AND s.Next_active_from_CET >= pci.applied_from
			AND s.Next_active_from_CET < ISNULL( pci.applied_to, '9999-12-31' )
	JOIN sourceNuudlNetCrackerView.pimnrmlprodofferingpricespecification_History ps
		ON ps.id = pck.prod_offering_price_spec_id
	WHERE pck.prod_offering_id = s.ProductKey
		AND s.Next_active_from_CET >= pck.available_from_CET
		AND s.Next_active_from_CET < ISNULL( pck.available_to_CET, '9999-12-31' )
		AND ps.name IN ('Monthly Fee', 'Activation Fee')		
) old
OUTER APPLY (
	SELECT 
		MAX(CASE WHEN ps.name = 'Monthly Fee' THEN pci.amount ELSE null END) NewMonthlyFee,
		MAX(CASE WHEN ps.name = 'Activation Fee' THEN pci.amount ELSE null END) NewActivationFee
	FROM sourceNuudlNetCrackerView.pimnrmlproductofferingpricechargekey_History pck
	INNER JOIN sourceNuudlNetCrackerView.pimnrmlproductofferingpricechargeitem_History pci
		ON pci.price_key_id = pck.id
			AND s.Next_active_from_CET >= pci.applied_from
			AND s.Next_active_from_CET < ISNULL( pci.applied_to, '9999-12-31' )
	JOIN sourceNuudlNetCrackerView.pimnrmlprodofferingpricespecification_History ps
		ON ps.id = pck.prod_offering_price_spec_id
	WHERE pck.prod_offering_id = s.NextProductKey
		AND s.Next_active_from_CET >= pck.available_from_CET
		AND s.Next_active_from_CET < ISNULL( pck.available_to_CET, '9999-12-31' )
		AND ps.name IN ('Monthly Fee', 'Activation Fee')		
) new
WHERE s.NextProductName <> s.ProductName and s.active_from_CET< s.Next_active_from_CET
AND NOT EXISTS (SELECT 1 FROM #all_lines_filtered_2 alf 
where
alf.SubscriptionKey = s.subscriptionkey and alf.ProductName = s.NextProductName and s.active_from_CET <alf.active_from_CET and s.Next_active_from_CET >alf.active_from_CET and alf.OrderEventKey='093')

--	AND s.subscriptionkey = '0edb89b6-2ffa-4884-8fd6-d6e49d3dd837'


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
	s.SubscriptionOriginalKey,
	s.QuoteKey,
	s.QuoteItemKey,
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
	s.ThirdPartyStoreKey,
	s.IsTLO,
	s.active_from_CET
INTO #migration_lines
FROM #migration_lines_with_prices s
CROSS APPLY (
	SELECT *
	FROM dim.OrderEvent 
	WHERE OrderEventName = 
		CASE	
			WHEN s.NewMonthlyFee > s.OldMonthlyFee THEN 'Migration From Upgrade'
			WHEN s.NewMonthlyFee < s.OldMonthlyFee THEN 'Migration From Downgrade'
			ELSE 'Migration From'
		END
) e
WHERE 1=1
--	AND IsTLO = 1
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
	s.SubscriptionOriginalKey,
	s.QuoteKey,
	s.QuoteItemKey,
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
	s.ThirdPartyStoreKey,
	s.IsTLO,
	s.active_from_CET
INTO #change_lines
FROM #active_lines s
CROSS APPLY (
	SELECT *
	FROM dim.OrderEvent 
	WHERE OrderEventName = 'Migration To'
) e
WHERE s.PreviousProductName <> s.ProductName  and s.active_from_CET> s.Previous_active_from_CET
AND NOT EXISTS (SELECT 1 FROM #all_lines_filtered_2 alf 
where 
alf.SubscriptionKey = s.subscriptionkey and alf.ProductName = s.Productname and s.active_from_CET >alf.active_from_CET and s.Previous_active_from_CET <alf.active_from_CET and alf.OrderEventKey='093')




-- Creating Offer Disconnected lines if the offer is migrated
DROP TABLE IF EXISTS #disconnect_lines_from_migrations
SELECT 
	s.CalendarKey,
	DATEADD(ss, -1, s.TimeKey) TimeKey,
	s.ProductKey, 
	s.ProductParentKey,
	s.ProductHardwareKey,
	s.CustomerKey,
	s.SubscriptionGroup,
	s.SubscriptionKey,
	s.SubscriptionOriginalKey,
	s.QuoteKey,
	s.QuoteItemKey,
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
	s.ThirdPartyStoreKey,
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
	DATEADD(ss, -1, s.NextTimeTLO) TimeKey,
	s.ProductKey, 
	s.ProductParentKey,
	s.ProductHardwareKey,
	s.CustomerKey,
	s.SubscriptionGroup,
	s.SubscriptionKey,
	s.SubscriptionOriginalKey,
	s.QuoteKey,
	s.QuoteItemKey,
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
	s.ThirdPartyStoreKey,
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
	s.SubscriptionOriginalKey,
	s.QuoteKey,
	s.QuoteItemKey,
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
	s.ThirdPartyStoreKey,
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

-- Create Offer Planned if the subscription has been migrated from legacy
DROP TABLE IF EXISTS #planned_lines_from_migration_legacy
SELECT 
	s.CalendarKey,
	s.TimeKey,
	s.ProductKey, 
	s.ProductParentKey,
	s.ProductHardwareKey,
	s.CustomerKey,
	s.SubscriptionGroup,
	s.SubscriptionKey,
	s.SubscriptionOriginalKey,
	s.QuoteKey,
	s.QuoteItemKey,
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
	s.ThirdPartyStoreKey,
	s.IsTLO,
	s.active_from_CET
INTO #planned_lines_from_migration_legacy
FROM #migration_legacy_lines s
CROSS APPLY (
	SELECT *
	FROM dim.OrderEvent 
	WHERE OrderEventName = 'Offer Planned'
) e
WHERE 1=1


-- Create lines if owner of the subscription has changed
DROP TABLE IF EXISTS #changed_owner
SELECT 
	s.CalendarKey,
	s.TimeKey,
	s.ProductKey, 
	s.ProductParentKey,
	s.ProductHardwareKey,
	s.CustomerKey,
	s.SubscriptionGroup,
	s.SubscriptionKey,
	s.SubscriptionOriginalKey,
	s.QuoteKey,
	s.QuoteItemKey,
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
	s.ThirdPartyStoreKey,
	s.IsTLO,
	s.active_from_CET
INTO #changed_owner
FROM #active_lines s
CROSS APPLY (
	SELECT *
	FROM dim.OrderEvent 
	WHERE OrderEventName = 'Offer Changed Owner'
) e
WHERE 1=1 
	AND s.IsTLO = 1
	AND s.SubscriptionKey <> s.SubscriptionOriginalKey 
	AND EXISTS (
		SELECT * 
		FROM #all_lines 
		WHERE SubscriptionOriginalKey = s.SubscriptionOriginalKey 
			AND QuoteKey = s.QuoteKey
			AND CurrentState = 'DISCONNECTED' AND IsTLO=1
		)

-----------------------------------------------------------------------------------------------------------------------------
-- Insert everyting into result set
-----------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #result
SELECT *
INTO #result
FROM (

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, SubscriptionOriginalKey, QuoteKey, QuoteItemKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, ThirdPartyStoreKey, null TicketKey, IsTLO, 1 Quantity
		,active_from_CET
	FROM #all_lines_filtered_2
	WHERE OrderEventKey IS NOT NULL
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, SubscriptionOriginalKey, QuoteKey, QuoteItemKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, ThirdPartyStoreKey, TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #hardware_return_lines
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, null AS ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, SubscriptionOriginalKey, QuoteKey, QuoteItemKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, ThirdPartyStoreKey, TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #termination_lines
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, null AS ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, SubscriptionOriginalKey, QuoteKey, QuoteItemKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, ThirdPartyStoreKey, null TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #migration_legacy_lines
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, null AS ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, SubscriptionOriginalKey, QuoteKey, QuoteItemKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, ThirdPartyStoreKey, null TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #migration_lines
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, null AS ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, SubscriptionOriginalKey, QuoteKey, QuoteItemKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, ThirdPartyStoreKey, null TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #disconnect_lines_from_migrations

	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, null AS ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, SubscriptionOriginalKey, QuoteKey, QuoteItemKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, ThirdPartyStoreKey, null TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #disconnect_lines_from_product_type_change

	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, null AS ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, SubscriptionOriginalKey, QuoteKey, QuoteItemKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, ThirdPartyStoreKey, null TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #planned_lines_from_product_type_change

	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, null AS ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, SubscriptionOriginalKey, QuoteKey, QuoteItemKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, ThirdPartyStoreKey, null TicketKey, IsTLO, 0 Quantity 
		,active_from_CET
	FROM #planned_lines_from_migration_legacy	
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, null AS ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, SubscriptionOriginalKey, QuoteKey, QuoteItemKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, ThirdPartyStoreKey, null TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #change_lines
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, SubscriptionOriginalKey, QuoteKey, QuoteItemKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, ThirdPartyStoreKey, null TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #commitment_lines
	
	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, SubscriptionOriginalKey, QuoteKey, QuoteItemKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, ThirdPartyStoreKey, null TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #rgu_lines

	UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, SubscriptionOriginalKey, QuoteKey, QuoteItemKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, ThirdPartyStoreKey, null TicketKey, IsTLO, 1 Quantity 
		,active_from_CET
	FROM #changed_owner


UNION ALL

	SELECT CalendarKey, TimeKey, ProductKey, ProductParentKey, null AS ProductHardwareKey, CustomerKey, SubscriptionGroup, SubscriptionKey, SubscriptionOriginalKey, QuoteKey, QuoteItemKey, OrderEventKey, OrderEventName, 
		ProductType, ProductName, SalesChannelKey, BillingAccountKey, PhoneDetailKey, AddressBillingKey, HouseHoldKey, TechnologyKey, EmployeeKey, ThirdPartyStoreKey, TicketKey, IsTLO, Quantity 
		,active_from_CET
	FROM #future_migrations_lines

) q


CREATE CLUSTERED INDEX CLIX ON #result (SubscriptionKey,IsTLO,OrderEventName,active_from_CET)



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
			WHERE SubscriptionOriginalKey = ra.SubscriptionOriginalKey 
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
	--and SubscriptionKey in('07a7c6f7-6d33-48ae-b294-4709c1183bc7','8405435a-5862-491b-b70e-74891f565896')
	AND EXISTS (
		SELECT * 
		FROM #result 
		WHERE SubscriptionOriginalKey = ra.SubscriptionOriginalKey 
			AND SubscriptionGroup = ra.SubscriptionGroup
			AND ( OrderEventName = REPLACE(ra.OrderEventName,'Disconnected','Activated') )
			AND IsTLO = ra.IsTLO
			AND active_from_CET > ra.active_from_CET
	)
	--AND ra.SubscriptionKey = '2e3e5b05-c86a-4e47-a731-eea2cab36dcf'

-- update dissconnections happened at the same date as Activation - Ownership change
UPDATE ra
SET Quantity = 0
--SELECT ra.*
FROM #result ra
WHERE 1=1
	AND ra.IsTLO = 1 and quantity=1
	AND ra.OrderEventName IN ('Offer Disconnected')
	--and SubscriptionKey in('07a7c6f7-6d33-48ae-b294-4709c1183bc7','8405435a-5862-491b-b70e-74891f565896')
	AND EXISTS (
		SELECT * 
		FROM #result 
		WHERE SubscriptionOriginalKey = ra.SubscriptionOriginalKey 
			AND SubscriptionKey <> ra.SubscriptionKey
			AND SubscriptionGroup = ra.SubscriptionGroup
			AND  OrderEventName = 'Offer Activated'
			AND IsTLO = ra.IsTLO
			AND active_from_CET >= ra.active_from_CET
			)

-- Migrated from legacy to NetCracker / Dawn
UPDATE ra
SET Quantity = 0
--SELECT ra.*
FROM #result ra
WHERE 1=1
	AND ra.OrderEventName IN ('RGU Activated', 'Offer Activated', 'Offer Planned')
	AND EXISTS (
			SELECT * 
			FROM #result 
			WHERE SubscriptionOriginalKey = ra.SubscriptionOriginalKey 
				AND OrderEventName = 'Migration Legacy'
				AND active_from_CET >= ra.active_from_CET
	)

	
-- If a Offer Planned already has been registered on the subcription
UPDATE ra
SET Quantity = 0
--SELECT ra.*
FROM #result ra
WHERE 1=1
	AND ra.IsTLO = 1
	AND ra.OrderEventName IN ( 'Offer Planned')
	AND EXISTS (
			SELECT * 
			FROM #result 
			WHERE SubscriptionOriginalKey = ra.SubscriptionOriginalKey 
				AND OrderEventName = 'Offer Planned'
				AND ProductType = ra.ProductType
				AND active_from_CET < ra.active_from_CET
	)

-----------------------------------------------------------------------------------------------------------------------------
-- Creating Offer Disconnect Planned lines where these aren't provided by tickets
-----------------------------------------------------------------------------------------------------------------------------


DROP TABLE IF EXISTS #missing_planned_disconnect

SELECT r.*
INTO #missing_planned_disconnect
FROM #result r  
OUTER APPLY (
	SELECT MAX(active_from_CET) activated_date
	FROM #result
	WHERE 1=1
			AND SubscriptionKey = r.SubscriptionKey 
			AND IsTLO=1 
			AND OrderEventName = 'Offer Activated'
			AND active_from_CET < r.active_from_CET
) a
WHERE 1=1
	AND OrderEventName = 'Offer Disconnected' 
	AND IsTLO = 1
	AND Quantity = 1
	AND NOT EXISTS (
		SELECT *
		FROM #result 
		WHERE 1=1
			AND SubscriptionKey = r.SubscriptionKey 
			AND IsTLO=1 
			AND OrderEventName = 'Offer Disconnected Planned'
			AND active_from_CET >= a.activated_date
	)

UPDATE a
SET 
	OrderEventKey = e.OrderEventKey,
	OrderEventName = e.OrderEventName
FROM #missing_planned_disconnect a
CROSS APPLY (
	SELECT *
	FROM dim.OrderEvent 
	WHERE OrderEventName = 'Offer Disconnected Planned'
) e

INSERT INTO #result ([CalendarKey], [TimeKey], [ProductKey], [ProductParentKey], [ProductHardwareKey], [CustomerKey],[SubscriptionGroup], [SubscriptionKey],[SubscriptionOriginalKey], [QuoteKey], QuoteItemKey, [OrderEventKey],[OrderEventName],[ProductType], [ProductName], [SalesChannelKey], [BillingAccountKey], 
	[PhoneDetailKey], [AddressBillingKey], [HouseHoldKey], TechnologyKey, EmployeeKey, TicketKey, ThirdPartyStoreKey, [IsTLO], [Quantity],active_from_CET)
SELECT [CalendarKey], [TimeKey], [ProductKey], [ProductParentKey], [ProductHardwareKey], [CustomerKey],[SubscriptionGroup], [SubscriptionKey],[SubscriptionOriginalKey], [QuoteKey], QuoteItemKey, [OrderEventKey],[OrderEventName],[ProductType], [ProductName], [SalesChannelKey], [BillingAccountKey], 
	[PhoneDetailKey], [AddressBillingKey], [HouseHoldKey], TechnologyKey, EmployeeKey, TicketKey, ThirdPartyStoreKey, [IsTLO], [Quantity],active_from_CET
FROM #missing_planned_disconnect

-----------------------------------------------------------------------------------------------------------------------------
-- Truncate and insert into stage table
-----------------------------------------------------------------------------------------------------------------------------

TRUNCATE TABLE [stage].[Fact_OrderEvents]

INSERT INTO [stage].[Fact_OrderEvents] WITH (TABLOCK) ([CalendarKey], [TimeKey], [ProductKey], [ProductParentKey], [ProductHardwareKey], [CustomerKey], [SubscriptionKey], [QuoteKey], QuoteItemKey, [OrderEventKey], [SalesChannelKey], [BillingAccountKey], 
	[PhoneDetailKey], [AddressBillingKey], [HouseHoldKey], TechnologyKey, EmployeeKey, TicketKey, ThirdPartyStoreKey, [IsTLO], [Quantity])
SELECT
	CalendarKey,
	TimeKey,
	ProductKey,
	ProductParentKey,
	ProductHardwareKey,
	CustomerKey,
	SubscriptionKey,
	QuoteKey,
	QuoteItemKey,
	OrderEventKey,
	SalesChannelKey,
	BillingAccountKey,
	PhoneDetailKey,
	AddressBillingKey,
	HouseHoldKey,
	TechnologyKey,
	EmployeeKey, 
	TicketKey,
	ThirdPartyStoreKey,
	IsTLO,
	Quantity
FROM #result
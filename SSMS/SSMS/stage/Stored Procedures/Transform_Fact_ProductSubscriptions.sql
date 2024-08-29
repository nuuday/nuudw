
CREATE PROCEDURE [stage].[Transform_Fact_ProductSubscriptions]
	@JobIsIncremental BIT			
AS 

/* Taking a copy of order events that are non-hardware sales */

DROP TABLE IF EXISTS #order_events
SELECT
	CONCAT(CONVERT(CHAR(10),f.CalendarKey,120), ' ', f.TimeKey) ActualDate,
	f.CalendarKey,
	f.TimeKey,
	f.SubscriptionKey,
	f.OrderEventKey,
	f.CustomerKey,
	f.ProductKey,
	f.SalesChannelKey,
	f.AddressBillingKey,
	f.BillingAccountKey,
	f.PhoneDetailKey,
	f.TechnologyKey,
	f.EmployeeKey,
	f.QuoteKey,
	f.QuoteItemKey,
	e.OrderEventName,
	CASE 
		WHEN p.ProductType = 'Mobile Voice Offline' THEN 'Mobile Voice'
		WHEN p.ProductType = 'Mobile Voice Broadband' THEN 'Mobile Broadband'
		ELSE p.ProductType
	END ProductType,
	f.Quantity
INTO #order_events
FROM stage.Fact_OrderEvents f
INNER JOIN dim.OrderEvent e ON e.OrderEventKey = f.OrderEventKey
INNER JOIN dim.Product p ON p.ProductKey = f.ProductKey
WHERE f.IsTLO = 1
	AND f.ProductKey <> ISNULL(f.ProductHardwareKey,'')
--	AND f.SubscriptionKey = '7ef4c36b-62a2-4aab-bd51-59bc0caa485c'


/* Setting RGU activated to same time as Offer activated so it wont overlap if its a part of a migration - it wont change the reported RGU activated date  */

UPDATE rgu
SET ActualDate = o.ActualDate
--SELECT o.ActualDate, rgu.*
FROM #order_events rgu
CROSS APPLY (
	SELECT TOP 1 ActualDate
	FROM #order_events
	WHERE SubscriptionKey = rgu.SubscriptionKey
		AND ProductKey = rgu.ProductKey
		AND OrderEventKey = '065' /* Offer Activated */ 
		AND CalendarKey = rgu.CalendarKey
	ORDER BY ActualDate DESC
	) o
WHERE OrderEventKey = '100' /* RGU Activated */ 



/* Grouping the subscription into group in the event that the product type has changed. We can identify this based on Offer Planned */

DROP TABLE IF EXISTS #order_events_2

SELECT oe.*, ISNULL(sg.SubscriptionGroup,0) SubscriptionGroup
INTO #order_events_2
FROM #order_events oe
LEFT JOIN (
	SELECT 
		ActualDate AS ActualDateFrom,
		ISNULL(LEAD(ActualDate,1) OVER (PARTITION BY SubscriptionKey ORDER BY ActualDate),'9999-12-31 00:00:00') ActualDateTo,
		SubscriptionKey,
		ProductType,
		SUM(1) OVER (PARTITION BY SubscriptionKey ORDER BY CalendarKey, TimeKey) AS SubscriptionGroup
	FROM #order_events
	WHERE 1=1
		AND OrderEventName = 'Offer Planned'	
		--AND SubscriptionKey = '0457e006-45bc-426f-9b3c-4507d88c24d1'
	) sg 
	ON sg.SubscriptionKey = oe.SubscriptionKey 
		AND sg.ProductType = oe.ProductType
		AND oe.ActualDate BETWEEN sg.ActualDateFrom AND sg.ActualDateTo
--ORDER BY 1


/* Get all relevant dates to an subscription */

DROP TABLE IF EXISTS #subscription_dates

SELECT DISTINCT 
	CalendarKey,
	SubscriptionKey,
	SubscriptionGroup
INTO #subscription_dates
FROM #order_events_2 f
WHERE 1=1
	AND OrderEventName IN (
		'Offer Planned',
		'Offer Cancelled',
		'Offer Activated',
		'Offer Disconnected',
		'Offer Disconnected Planned',
		'Offer Disconnected Expected',
		'Offer Disconnected Cancelled',
		'RGU Activated',
		'RGU Disconnected',
		'Offer Commitment Start',
		'Migration Legacy'
		)
	AND 
		CASE 
			WHEN OrderEventName IN ('Offer Activated') THEN 1
			ELSE Quantity
		END = 1
	--AND f.SubscriptionKey = '60e05fb6-1194-4531-9f86-7e70ac3d4594'


/* Setting the whole date interval */ 

DROP TABLE IF EXISTS #subscription_dates_type2
SELECT 
	CalendarKey AS CalendarFromKey,
	ISNULL( DATEADD(dd, -1, LEAD(CalendarKey,1) OVER (PARTITION BY SubscriptionKey, SubscriptionGroup ORDER BY CalendarKey) ) , '9999-12-31')  AS CalendarToKey,  
	SubscriptionKey,
	SubscriptionGroup
INTO #subscription_dates_type2
FROM #subscription_dates


/* For each date interval we fetch relevant dates and keys, and insert the result into the stage table. */

TRUNCATE TABLE [stage].[Fact_ProductSubscriptions]

INSERT INTO stage.[Fact_ProductSubscriptions] WITH (TABLOCK) ([CalendarFromKey], [CalendarToKey], [SubscriptionKey], [ProductKey], [CustomerKey], [SalesChannelKey], [AddressBillingKey], [BillingAccountKey], [PhoneDetailKey], [TechnologyKey], [EmployeeKey], [QuoteKey], [QuoteItemKey], [CalendarPlannedKey], [CalendarActivatedKey], [CalendarDisconnectedPlannedKey], [CalendarDisconnectedExpectedKey], [CalendarDisconnectedCancelledKey], [CalendarDisconnectedKey], [CalendarRGUFromKey], [CalendarRGUToKey], [CalendarMigrationLegacyKey])
SELECT
	sdt.CalendarFromKey,
	COALESCE( sdt.CalendarToKey, '9999-12-31' ) AS CalendarToKey,
	sdt.SubscriptionKey,
	keys2.ProductKey,
	keys.[CustomerKey],
	keys.[SalesChannelKey],
	keys.[AddressBillingKey],
	keys.[BillingAccountKey],
	keys2.[PhoneDetailkey],
	keys.[TechnologyKey],
	keys.[EmployeeKey],
	keys.[QuoteKey],
	keys.[QuoteItemKey],
	dates.[CalendarPlannedKey],
	dates.[CalendarActivatedKey],
	dates.[CalendarDisconnectedPlannedKey],
	dates.[CalendarDisconnectedExpectedKey],
	dates.[CalendarDisconnectedCancelledKey],
	dates.[CalendarDisconnectedKey],
	dates.[CalendarRGUFromKey],
	dates.[CalendarRGUTokey],
	dates.[CalendarMigrationLegacyKey]
--select *
FROM #subscription_dates_type2 sdt
INNER JOIN dim.Subscription s 
	ON s.SubscriptionKey = sdt.SubscriptionKey
		AND s.SubscriptionValidFromDate <= DATEADD(ss,60*60*24-1,CAST(sdt.CalendarFromKey as datetime2(0))) -- end of day
		AND s.SubscriptionValidToDate > DATEADD(ss,60*60*24-1,CAST(sdt.CalendarFromKey as datetime2(0))) -- end of day
OUTER APPLY (
	SELECT 
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Planned' THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarPlannedKey,
		ISNULL(MAX(CASE WHEN OrderEventName IN ('Offer Activated', 'Migration Legacy') THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarActivatedKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Disconnected Planned' THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarDisconnectedPlannedKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Disconnected Expected' THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarDisconnectedExpectedKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Disconnected Cancelled' THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarDisconnectedCancelledKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Disconnected' THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarDisconnectedKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'RGU Activated' THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarRGUFromKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'RGU Disconnected' THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarRGUToKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Migration Legacy' THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarMigrationLegacyKey
	FROM #order_events_2
	WHERE 1=1
		AND SubscriptionKey = sdt.SubscriptionKey
		AND SubscriptionGroup = sdt.SubscriptionGroup
		AND OrderEventName IN (
			'Offer Planned',
			'Offer Cancelled',
			'Offer Activated',
			'Offer Disconnected',
			'Offer Disconnected Planned',
			'Offer Disconnected Expected',
			'Offer Disconnected Cancelled',
			'RGU Activated',
			'RGU Disconnected',
			'Migration Legacy'
			)
		AND Quantity = 1
		AND CalendarKey <= sdt.CalendarFromKey
) dates
OUTER APPLY (
	SELECT TOP 1 CustomerKey, SalesChannelKey, AddressBillingKey, BillingAccountKey, PhoneDetailKey, TechnologyKey, EmployeeKey, QuoteKey, QuoteItemKey
	FROM #order_events_2
	WHERE 1=1
		AND OrderEventName = 'Offer Planned'
		AND SubscriptionKey = sdt.SubscriptionKey
		AND SubscriptionGroup = sdt.SubscriptionGroup
		--AND Quantity = 1
	ORDER BY CalendarKey DESC, TimeKey DESC
) keys
/* 
Keys we expect to be in at the latest in event.
*/ 
OUTER APPLY (
	SELECT TOP 1 ProductKey, PhoneDetailKey
	FROM #order_events_2
	WHERE 1=1
		AND OrderEventName IN ('Offer Planned','Offer Activated','Offer Disconnected')
		AND SubscriptionKey = sdt.SubscriptionKey
		AND SubscriptionGroup = sdt.SubscriptionGroup
		--AND CalendarKey <= sdt.CalendarFromKey
	ORDER BY CalendarKey DESC, TimeKey DESC
) keys2
--ORDER BY 1,2 DESC
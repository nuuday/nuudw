

CREATE PROCEDURE [stage].[Transform_Fact_ProductSubscriptions]
	@JobIsIncremental BIT			
AS 

/* Taking a copy of order events that are non-hardware sales */

DROP TABLE IF EXISTS #order_events
SELECT
	CONCAT( CONVERT( CHAR(10), f.CalendarKey, 120 ), ' ', f.TimeKey ) ActualDate,
	f.CalendarKey,
	f.TimeKey,
	f.SubscriptionKey,
	s.SubscriptionOriginalKey,
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
		WHEN p.ProductType = 'Mobile Broadband Offline' THEN 'Mobile Broadband'
		ELSE p.ProductType
	END ProductType,
	f.Quantity
INTO #order_events
FROM stage.Fact_OrderEvents f
INNER JOIN dimView.Subscription s
	ON CONVERT( DATETIME2(0), CONCAT( f.[CalendarKey], ' ', [TimeKey] ) ) >= s.[SubscriptionValidFromDate]
		AND CONVERT( DATETIME2(0), CONCAT( f.[CalendarKey], ' ', [TimeKey] ) ) < s.[SubscriptionValidToDate]
		AND s.[SubscriptionKey] = f.[SubscriptionKey]
		AND s.DWIsDeleted <> 1
INNER JOIN dimView.OrderEvent e
	ON e.OrderEventKey = f.OrderEventKey
INNER JOIN dimView.Product p
	ON p.ProductKey = f.ProductKey
WHERE
	f.IsTLO = 1
	AND NOT (e.OrderEventName LIKE 'Offer Planned' and f.TicketKey is null)
	AND f.ProductKey <> ISNULL( f.ProductHardwareKey, '' )
	AND e.OrderEventName NOT LIKE 'Offer Commitment%'
	--AND f.SubscriptionKey = '04e198b4-7747-42ce-8a9d-2a03bba4c673' --'56b0bec5-6639-4b86-a133-814562d8bb14' --
	--order by 1
	

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
		AND ActualDate >= rgu.ActualDate
	ORDER BY ActualDate 
	) o
WHERE OrderEventKey = '100' /* RGU Activated */ 

/*
UPDATE rgu
SET  ActualDate = o.ActualDate
--SELECT o.ActualDate, rgu.*
FROM #order_events rgu
CROSS APPLY (
	SELECT TOP 1 ActualDate
	FROM #order_events
	WHERE SubscriptionKey = rgu.SubscriptionKey
		--AND ProductKey = rgu.ProductKey
		AND OrderEventKey = '100' /* RGU Activated */ 
		AND ActualDate <= rgu.ActualDate
	ORDER BY ActualDate DESC
	) o
WHERE OrderEventKey = '101' /* RGU Disconnected */ 
*/

/* Grouping the subscription into group in the event that the product type has changed. We can identify this based on Offer Planned */

DROP TABLE IF EXISTS #order_events_2

SELECT oe.*, ISNULL(sg.SubscriptionGroup,0) SubscriptionGroup
INTO #order_events_2
FROM #order_events oe
LEFT JOIN (
	SELECT 
		ActualDate AS ActualDateFrom,
		ISNULL(LEAD(ActualDate,1) OVER (PARTITION BY SubscriptionOriginalKey ORDER BY ActualDate),'9999-12-31 00:00:00') ActualDateTo,
		SubscriptionKey,
		SubscriptionOriginalKey,
		ProductType,
		SUM(1) OVER (PARTITION BY SubscriptionOriginalKey ORDER BY CalendarKey, TimeKey) AS SubscriptionGroup
	FROM #order_events
	WHERE 1=1
		AND OrderEventName IN ('Offer Planned')
	) sg 
	ON sg.SubscriptionOriginalKey = oe.SubscriptionOriginalKey 
		AND sg.ProductType = oe.ProductType
		AND oe.ActualDate BETWEEN sg.ActualDateFrom AND sg.ActualDateTo

		

/* Get all relevant dates to an subscription */

DROP TABLE IF EXISTS #subscription_dates

SELECT DISTINCT 
	cast(actualdate as date) as CalendarKey,
	--max(LEFT( CONVERT( VARCHAR, CAST(actualdate AS datetime2(0)), 108 ), 8 )) over (PARTITION BY SubscriptionOriginalKey,SubscriptionKey,SubscriptionGroup,CalendarKey ORDER BY CalendarKey)  AS TimeKey,
	MIN(LEFT( CONVERT( VARCHAR, CAST(actualdate AS datetime2(0)), 108 ), 8 )) over (PARTITION BY SubscriptionOriginalKey,SubscriptionKey,SubscriptionGroup,productkey,cast(actualdate as date) ORDER BY cast(actualdate as date))  AS TimeKey,
	SubscriptionKey,
	SubscriptionOriginalKey,
	SubscriptionGroup,
	ProductKey
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


/* Setting the whole date interval */ 

DROP TABLE IF EXISTS #subscription_dates_type2
SELECT 
	CalendarKey AS CalendarFromKey,
	TimeKey as TimeFromKey,
	ISNULL(  LEAD(CONVERT(DATE,DATEADD(ss, -1,CONCAT( CONVERT( CHAR(10), CalendarKey, 120 ), ' ', TimeKey ))),1) OVER (PARTITION BY SubscriptionOriginalKey,SubscriptionGroup ORDER BY Calendarkey,timekey ) , '9999-12-31')  AS CalendarToKey,  
	ISNULL(  LEAD(LEFT( CONVERT( VARCHAR, CAST(DATEADD(ss, -1,CONCAT( CONVERT( CHAR(10), CalendarKey, 120 ), ' ', TimeKey )) AS datetime2(0)), 108 ), 8 ),1) OVER (PARTITION BY SubscriptionOriginalKey,SubscriptionGroup ORDER BY Calendarkey,timekey) , '00:00:00')  AS TimeToKey, 
	SubscriptionKey,
	SubscriptionOriginalKey,
	SubscriptionGroup,
	ProductKey
INTO #subscription_dates_type2
FROM #subscription_dates


/* For each date interval we fetch relevant dates and keys, and insert the result into the stage table. */

TRUNCATE TABLE [stage].[Fact_ProductSubscriptions]

INSERT INTO stage.[Fact_ProductSubscriptions] WITH (TABLOCK) ([CalendarFromKey],[TimeFromKey], [CalendarToKey],[TimeToKey], [SubscriptionKey], [ProductKey], [CustomerKey], [SalesChannelKey], [AddressBillingKey], [BillingAccountKey], [PhoneDetailKey], [TechnologyKey], [EmployeeKey], [QuoteKey], [QuoteItemKey], [CalendarPlannedKey], [CalendarActivatedKey], [CalendarCancelledKey], [CalendarDisconnectedPlannedKey], [CalendarDisconnectedExpectedKey], [CalendarDisconnectedCancelledKey], [CalendarDisconnectedKey], [CalendarRGUFromKey], [CalendarRGUToKey], [CalendarMigrationLegacyKey],
[TimePlannedKey],[TimeActivatedKey],[TimeCancelledKey],[TimeDisconnectedPlannedKey],[TimeDisconnectedExpectedKey],[TimeDisconnectedCancelledKey],[TimeDisconnectedKey],[TimeRGUFromKey],[TimeRGUTokey],[TimeMigrationLegacyKey])
SELECT
	sdt.CalendarFromKey,
	sdt.TimeFromKey,
	COALESCE( sdt.CalendarToKey, '9999-12-31' ) AS CalendarToKey,
	sdt.TimeToKey,
	sdt.SubscriptionKey,
	sdt.Productkey,--COALESCE(keys2.ProductKey,LEAD(keys2.ProductKey,1) OVER (PARTITION BY sdt.SubscriptionKey ORDER BY CalendarFromKey)) AS ProductKey,
	keys.[CustomerKey],
	keys.[SalesChannelKey],
	keys.[AddressBillingKey],
	keys.[BillingAccountKey],
	keys3.[PhoneDetailkey],
	keys.[TechnologyKey],
	keys.[EmployeeKey],
	keys.[QuoteKey],
	keys.[QuoteItemKey],
	dates.[CalendarPlannedKey],
	dates.[CalendarActivatedKey],
	dates.[CalendarCancelledKey],
	dates.[CalendarDisconnectedPlannedKey],
	dates.[CalendarDisconnectedExpectedKey],
	dates.[CalendarDisconnectedCancelledKey],
	dates.[CalendarDisconnectedKey],
	dates.[CalendarRGUFromKey],
	dates.[CalendarRGUTokey],
	dates.[CalendarMigrationLegacyKey],
	dates.[TimePlannedKey],
	dates.[TimeActivatedKey],
	dates.[TimeCancelledKey],
	dates.[TimeDisconnectedPlannedKey],
	dates.[TimeDisconnectedExpectedKey],
	dates.[TimeDisconnectedCancelledKey],
	dates.[TimeDisconnectedKey],
	dates.[TimeRGUFromKey],
	dates.[TimeRGUTokey],
	dates.[TimeMigrationLegacyKey]
--select *
FROM #subscription_dates_type2 sdt
/*INNER JOIN dim.Subscription s 
	ON s.SubscriptionKey = sdt.SubscriptionKey
		AND s.SubscriptionValidFromDate <= DATEADD(ss,60*60*24-1,CAST(sdt.CalendarFromKey as datetime2(0))) -- end of day
		AND s.SubscriptionValidToDate > DATEADD(ss,60*60*24-1,CAST(sdt.CalendarFromKey as datetime2(0))) -- end of day		
		AND s.DWIsDeleted <> 1 */
OUTER APPLY (
	SELECT 
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Planned' THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarPlannedKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Planned' THEN Timekey ELSE NULL END),'00:00:00') TimePlannedKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Cancelled' THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarCancelledKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Cancelled' THEN Timekey ELSE NULL END),'00:00:00') TimeCancelledKey,
		ISNULL(MAX(CASE WHEN OrderEventName IN ('Offer Activated', 'Migration Legacy') THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarActivatedKey,
		ISNULL(MAX(CASE WHEN OrderEventName IN ('Offer Activated', 'Migration Legacy') THEN Timekey ELSE NULL END),'00:00:00') TimeActivatedKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Disconnected Planned' THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarDisconnectedPlannedKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Disconnected Planned' THEN Timekey ELSE NULL END),'00:00:00') TimeDisconnectedPlannedKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Disconnected Expected' THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarDisconnectedExpectedKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Disconnected Expected' THEN Timekey ELSE NULL END),'00:00:00') TimeDisconnectedExpectedKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Disconnected Cancelled' THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarDisconnectedCancelledKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Disconnected Cancelled' THEN Timekey ELSE NULL END),'00:00:00') TimeDisconnectedCancelledKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Disconnected' THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarDisconnectedKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Disconnected' THEN Timekey ELSE NULL END),'00:00:00') TimeDisconnectedKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'RGU Activated' THEN cast(actualdate as date) ELSE NULL END),'1900-01-01') CalendarRGUFromKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'RGU Activated' THEN LEFT( CONVERT( VARCHAR, CAST(actualdate AS datetime2(0)), 108 ), 8 ) ELSE NULL END),'00:00:00') TimeRGUFromKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'RGU Disconnected' THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarRGUToKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'RGU Disconnected' THEN TimeKey ELSE NULL END),'00:00:00') TimeRGUToKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Migration Legacy' THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarMigrationLegacyKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Migration Legacy' THEN TimeKey ELSE NULL END),'00:00:00') TimeMigrationLegacyKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Changed Owner' THEN CalendarKey ELSE NULL END),'1900-01-01') CalendarChangedOwnerKey,
		ISNULL(MAX(CASE WHEN OrderEventName = 'Offer Changed Owner' THEN TimeKey ELSE NULL END),'00:00:00') TimeChangedOwnerKey
	FROM #order_events_2
	WHERE 1=1
		AND SubscriptionOriginalKey = sdt.SubscriptionOriginalKey
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
		AND --CONCAT( CONVERT( CHAR(10), CalendarKey, 120 ), ' ', TimeKey ) 
		actualdate <= CONCAT( CONVERT( CHAR(10), sdt.CalendarToKey, 120 ), ' ', sdt.TimeToKey )
		--AND CalendarKey <= sdt.CalendarFromKey
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

OUTER APPLY (
	SELECT TOP 1 ProductKey
	FROM #order_events_2
	WHERE 1=1
		AND OrderEventName IN ('Offer Planned','Offer Activated')
		AND SubscriptionOriginalKey = sdt.SubscriptionOriginalKey
		AND SubscriptionGroup = sdt.SubscriptionGroup
		AND CONCAT( CONVERT( CHAR(10), CalendarKey, 120 ), ' ', TimeKey ) < CONCAT( CONVERT( CHAR(10), sdt.CalendarToKey, 120 ), ' ', sdt.TimeToKey )
		--AND CalendarKey < sdt.CalendarToKey 
		ORDER BY CalendarKey DESC , TimeKey DESC
) keys2

*/ 

/* 
Keys we expect to be in at the latest in event.
*/ 
OUTER APPLY (
	SELECT TOP 1 PhoneDetailKey
	FROM #order_events_2
	WHERE 1=1
		AND OrderEventName IN ('Offer Planned','Offer Activated','Offer Disconnected')
		AND SubscriptionOriginalKey = sdt.SubscriptionOriginalKey
		AND SubscriptionGroup = sdt.SubscriptionGroup
		--AND CalendarKey <= sdt.CalendarFromKey
	ORDER BY CalendarKey DESC, TimeKey DESC
) keys3 

--where sdt.SubscriptionKey='70c75576-0493-4327-9fa4-f1e0658bd269'

--ORDER BY keys.TechnologyKey, 1,2 DESC

--ORDER BY keys.TechnologyKey, 1,2 DESC
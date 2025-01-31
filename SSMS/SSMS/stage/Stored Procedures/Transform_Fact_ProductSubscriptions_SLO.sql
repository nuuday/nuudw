


CREATE PROCEDURE [stage].[Transform_Fact_ProductSubscriptions_SLO]
	@JobIsIncremental BIT			
AS 

/* Taking a copy of order events that are non-hardware sales */

DROP TABLE IF EXISTS #order_events_SLO
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
	p.ProductType,
	f.Quantity
INTO #order_events_SLO
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
	f.IsTLO = 0
	AND NOT (e.OrderEventName LIKE 'Offer Planned' and f.TicketKey is not null)
	AND f.ProductKey <> ISNULL( f.ProductHardwareKey, '' )
	AND p.ProductType = 'TV Add Ons'
	AND e.OrderEventName NOT LIKE 'Offer Commitment%'
--and f.SubscriptionKey='de8043ed-b5cb-4ae3-98d0-03ed445b5f05'	

	--select * from #order_events_SLO  where SubscriptionKey='de8043ed-b5cb-4ae3-98d0-03ed445b5f05' order by 4,1 

	--select distinct SubscriptionKey from #order_events  where ordereventname='Migration To'

	

/*select count(distinct SubscriptionKey)--,o.ordereventname, p.productname,p.producttype,f.* 
from stage.Fact_OrderEvents_dupl_plan f
left join stage.Dim_Product p on p.productkey=f.productkey
left join stage.Dim_OrderEvent o on o.OrderEventKey= f.OrderEventKey
where --SubscriptionKey='de8043ed-b5cb-4ae3-98d0-03ed445b5f05' and 
p.ProductType = 'TV Add Ons' and ordereventname in ('Migration To', 'Migration From Downgrade', 'Migration From Upgrade')
order by 5,6 */



----Update quantity for migrations----
UPDATE ra
SET Quantity = 0
--SELECT ra.*
FROM #order_events_SLO ra
WHERE 1=1
	AND ra.OrderEventName IN ('Offer Activated','Offer Planned') 
	AND EXISTS (
			SELECT * 
			FROM #order_events_SLO 
			WHERE SubscriptionOriginalKey = ra.SubscriptionOriginalKey 
				--AND SubscriptionGroup = ra.SubscriptionGroup
				AND OrderEventName = ra.OrderEventName
				--AND IsTLO = ra.IsTLO
				AND ActualDate < ra.ActualDate
	)

UPDATE ra
SET Quantity = 0
--SELECT ra.*
FROM #order_events_SLO ra
WHERE 1=1
	and quantity=1
	AND ra.OrderEventName IN ('Offer Disconnected')
	--and SubscriptionKey in('07a7c6f7-6d33-48ae-b294-4709c1183bc7','8405435a-5862-491b-b70e-74891f565896')
	AND EXISTS (
		SELECT * 
		FROM #order_events_SLO 
		WHERE SubscriptionOriginalKey = ra.SubscriptionOriginalKey 
			AND SubscriptionKey = ra.SubscriptionKey
			--AND SubscriptionGroup = ra.SubscriptionGroup
			AND  OrderEventName = 'Offer Activated'
			AND ActualDate >= ra.ActualDate
			)

/* Grouping the subscription into group in the event that the product type has changed. We can identify this based on Offer Planned */
DROP TABLE IF EXISTS #order_events_SLO_2

SELECT oe.*, ISNULL(sg.SubscriptionGroup,0) SubscriptionGroup
INTO #order_events_SLO_2
FROM #order_events_SLO oe
LEFT JOIN (
	SELECT 
		ActualDate AS ActualDateFrom,
		ISNULL(dateadd(ss,-1,LEAD(ActualDate,1) OVER (PARTITION BY SubscriptionOriginalKey ORDER BY ActualDate)),'9999-12-31 00:00:00') ActualDateTo,
		SubscriptionKey,
		SubscriptionOriginalKey,
		ProductType,
		SUM(1) OVER (PARTITION BY SubscriptionOriginalKey ORDER BY CalendarKey, TimeKey) AS SubscriptionGroup
	FROM #order_events_SLO
	WHERE 1=1
		AND OrderEventName IN ('Offer Planned') and quantity=1
	) sg 
	ON sg.SubscriptionKey = oe.SubscriptionKey 
		AND sg.ProductType = oe.ProductType
		AND oe.ActualDate BETWEEN sg.ActualDateFrom AND sg.ActualDateTo

--select * from #order_events_SLO_2	order by 1

/* Get all relevant dates to an subscription */

DROP TABLE IF EXISTS #subscription_dates_SLO

SELECT DISTINCT 
	cast(actualdate as date) as CalendarKey,
	--max(LEFT( CONVERT( VARCHAR, CAST(actualdate AS datetime2(0)), 108 ), 8 )) over (PARTITION BY SubscriptionOriginalKey,SubscriptionKey,SubscriptionGroup,CalendarKey ORDER BY CalendarKey)  AS TimeKey,
	MIN(LEFT( CONVERT( VARCHAR, CAST(actualdate AS datetime2(0)), 108 ), 8 )) over (PARTITION BY SubscriptionOriginalKey,SubscriptionKey,SubscriptionGroup,productkey,cast(actualdate as date) ORDER BY cast(actualdate as date))  AS TimeKey,
	SubscriptionKey,
	SubscriptionOriginalKey,
	SubscriptionGroup,
	ProductKey
INTO #subscription_dates_SLO
FROM #order_events_SLO_2 f
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

DROP TABLE IF EXISTS #subscription_dates_type2_SLO
SELECT 
	CalendarKey AS CalendarFromKey,
	TimeKey as TimeFromKey,
	--ISNULL(  LEAD(CONVERT(DATE,DATEADD(ss, -1,CONCAT( CONVERT( CHAR(10), CalendarKey, 120 ), ' ', TimeKey ))),1) OVER (PARTITION BY SubscriptionOriginalKey ORDER BY Calendarkey,timekey ) , '9999-12-31')  AS CalendarToKey,  
	--ISNULL(  LEAD(LEFT( CONVERT( VARCHAR, CAST(DATEADD(ss, -1,CONCAT( CONVERT( CHAR(10), CalendarKey, 120 ), ' ', TimeKey )) AS datetime2(0)), 108 ), 8 ),1) OVER (PARTITION BY SubscriptionOriginalKey ORDER BY Calendarkey,timekey) , '00:00:00')  AS TimeToKey, 
	case when LEAD(SubscriptionGroup) OVER (PARTITION BY SubscriptionOriginalKey ORDER BY Calendarkey,timekey)=0 then '9999-12-31' else
	ISNULL(  LEAD(CONVERT(DATE,DATEADD(ss, -1,CONCAT( CONVERT( CHAR(10), CalendarKey, 120 ), ' ', TimeKey ))),1) OVER (PARTITION BY SubscriptionOriginalKey ORDER BY Calendarkey,timekey ) , '9999-12-31')  end AS CalendarToKey,  
	case when LEAD(SubscriptionGroup) OVER (PARTITION BY SubscriptionOriginalKey ORDER BY Calendarkey,timekey)=0 then '00:00:00' else
	ISNULL(  LEAD(LEFT( CONVERT( VARCHAR, CAST(DATEADD(ss, -1,CONCAT( CONVERT( CHAR(10), CalendarKey, 120 ), ' ', TimeKey )) AS datetime2(0)), 108 ), 8 ),1) OVER (PARTITION BY SubscriptionOriginalKey ORDER BY Calendarkey,timekey) , '00:00:00') end AS TimeToKey, 
	
	SubscriptionKey,
	SubscriptionOriginalKey,
	SubscriptionGroup,
	ProductKey
INTO #subscription_dates_type2_SLO
FROM #subscription_dates_SLO



/* For each date interval we fetch relevant dates and keys, and insert the result into the stage table. */

TRUNCATE TABLE [stage].[Fact_ProductSubscriptions_SLO]

INSERT INTO stage.[Fact_ProductSubscriptions_SLO] WITH (TABLOCK) ([CalendarFromKey],[TimeFromKey], [CalendarToKey],[TimeToKey], [SubscriptionKey], [ProductKey], [CustomerKey], [SalesChannelKey], [AddressBillingKey], [BillingAccountKey], [PhoneDetailKey], [TechnologyKey], [EmployeeKey], [QuoteKey], [QuoteItemKey], [CalendarPlannedKey], [CalendarActivatedKey], [CalendarCancelledKey], [CalendarDisconnectedPlannedKey], [CalendarDisconnectedExpectedKey], [CalendarDisconnectedCancelledKey], [CalendarDisconnectedKey], [CalendarRGUFromKey], [CalendarRGUToKey], [CalendarMigrationLegacyKey],[CalendarChangedOwnerKey],
[TimePlannedKey],[TimeActivatedKey],[TimeCancelledKey],[TimeDisconnectedPlannedKey],[TimeDisconnectedExpectedKey],[TimeDisconnectedCancelledKey],[TimeDisconnectedKey],[TimeRGUFromKey],[TimeRGUTokey],[TimeMigrationLegacyKey],[TimeChangedOwnerKey])
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
	dates.[CalendarChangedOwnerKey],
	dates.[TimePlannedKey],
	dates.[TimeActivatedKey],
	dates.[TimeCancelledKey],
	dates.[TimeDisconnectedPlannedKey],
	dates.[TimeDisconnectedExpectedKey],
	dates.[TimeDisconnectedCancelledKey],
	dates.[TimeDisconnectedKey],
	dates.[TimeRGUFromKey],
	dates.[TimeRGUTokey],
	dates.[TimeMigrationLegacyKey],
	dates.[TimeChangedOwnerKey]
--select *
FROM #subscription_dates_type2_SLO sdt
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
	FROM #order_events_SLO_2
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
			'Migration Legacy',
			'Offer Changed Owner'
			)
		AND Quantity = 1
		AND --CONCAT( CONVERT( CHAR(10), CalendarKey, 120 ), ' ', TimeKey ) 
		actualdate <= CONCAT( CONVERT( CHAR(10), sdt.CalendarToKey, 120 ), ' ', sdt.TimeToKey )
		--AND CalendarKey <= sdt.CalendarFromKey
) dates
OUTER APPLY (
	SELECT TOP 1 CustomerKey, SalesChannelKey, AddressBillingKey, BillingAccountKey, PhoneDetailKey, TechnologyKey, EmployeeKey, QuoteKey, QuoteItemKey
	FROM #order_events_SLO_2
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
	FROM #order_events_SLO_2
	WHERE 1=1
		AND OrderEventName IN ('Offer Planned','Offer Activated','Offer Disconnected')
		AND SubscriptionOriginalKey = sdt.SubscriptionOriginalKey
		AND SubscriptionGroup = sdt.SubscriptionGroup
		--AND CalendarKey <= sdt.CalendarFromKey
	ORDER BY CalendarKey DESC, TimeKey DESC
) keys3 
order by 1,2

--where sdt.SubscriptionKey='70c75576-0493-4327-9fa4-f1e0658bd269'

--ORDER BY keys.TechnologyKey, 1,2 DESC

--ORDER BY keys.TechnologyKey, 1,2 DESC
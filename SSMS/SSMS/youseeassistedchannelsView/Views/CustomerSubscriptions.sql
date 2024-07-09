
CREATE VIEW youseeassistedchannelsView.CustomerSubscriptions
AS

WITH subscriptions AS (

	SELECT  
		MAX(CASE WHEN e.OrderEventName = 'Offer Activated' THEN c.CalendarKey ELSE NULL END) DateFrom,
		ISNULL(MAX(CASE WHEN e.OrderEventName = 'Offer Disconnected' THEN c.CalendarKey ELSE NULL END), '9999-12-31') DateTo,	
		cu.CustomerKey,
		ba.BillingAccountKey,
		pr.ProductType
	FROM factView.[OrderEvents] f
	INNER JOIN dim.Calendar c ON c.CalendarID = f.CalendarID
	INNER JOIN dim.OrderEvent e ON e.OrderEventID = f.OrderEventID
	INNER JOIN dim.Customer cu ON cu.CustomerID = f.CustomerID
	INNER JOIN dim.Product pr ON pr.ProductID = f.ProductID
	INNER JOIN dim.BillingAccount ba ON ba.BillingAccountID = f.BillingAccountID
	WHERE 1=1
		AND e.OrderEventName IN (
			'Offer Activated',
			'Offer Disconnected'
			)
		AND Quantity = 1  
		AND IsTLO = 1
		AND f.ProductID <> f.ProductHardwareID
		AND pr.ProductType IN ('Mobile Voice','Mobile Voice Offline','Mobile Broadband','Mobile Broadband Offline')
	GROUP BY
		cu.CustomerKey,
		ba.BillingAccountKey,
		pr.ProductType
	
)

SELECT 
	CustomerKey, 
	BillingAccountKey,
	CAST(null as int) Fastnet,
	CAST(null as int) Internet,
	MAX(CASE WHEN ProductType IN ('Mobile Voice','Mobile Voice Offline') THEN 1 ELSE 0 END) MBB,
	MAX(CASE WHEN ProductType IN ('Mobile Broadband','Mobile Broadband Offline') THEN 1 ELSE 0 END) MV,	
	CAST(null as int) TV
FROM subscriptions s
WHERE GETDATE() BETWEEN DateFrom AND DateTo
GROUP BY 
	CustomerKey, 
	BillingAccountKey
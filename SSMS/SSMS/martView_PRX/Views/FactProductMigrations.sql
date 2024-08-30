
CREATE VIEW [martView_PRX].[FactProductMigrations]
AS
	SELECT 
		f.CalendarID, 
		f.TimeID, 
		f.SubscriptionID,
		f.CustomerID, 
		f.ProductID AS ProductFromID, 
		mt.ProductToID, 
		CASE WHEN e.OrderEventName LIKE '%Upgrade' THEN 1 ELSE 0 END AS IsUpgrade,
		CASE WHEN e.OrderEventName LIKE '%Downgrade' THEN 1 ELSE 0 END AS IsDowngrade
	FROM fact.OrderEvents f
	INNER JOIN dim.OrderEvent e 
		ON e.OrderEventID = f.OrderEventID
			AND OrderEventName LIKE 'Migration From%'
	INNER JOIN dim.Product p 
		ON p.ProductId = f.ProductID
	OUTER APPLY (
		SELECT fi.ProductID AS ProductToID, ei.OrderEventName
		FROM fact.OrderEvents fi
		INNER JOIN dim.OrderEvent ei 
			ON ei.OrderEventID = fi.OrderEventID
				AND ei.OrderEventName LIKE 'Migration To%'
		INNER JOIN dim.Product pi
			ON pi.ProductId = fi.ProductID
		WHERE fi.SubscriptionID = f.SubscriptionID
			AND fi.CalendarID = f.CalendarID
			AND fi.TimeID = f.TimeID
			AND 
				CASE
					WHEN pi.ProductType = 'Mobile Voice Offline' THEN 'Mobile Voice'
					WHEN pi.ProductType = 'Mobile Broadband Offline' THEN 'Mobile Broadband'
					ELSE pi.ProductType
				END =
				CASE
					WHEN p.ProductType = 'Mobile Voice Offline' THEN 'Mobile Voice'
					WHEN p.ProductType = 'Mobile Broadband Offline' THEN 'Mobile Broadband'
					ELSE p.ProductType
				END
	) mt
	--WHERE f.SubscriptionID=4143
	--ORDER BY f.SubscriptionID, f.CalendarID
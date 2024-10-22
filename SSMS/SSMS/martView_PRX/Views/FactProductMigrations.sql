


CREATE VIEW [martView_PRX].[FactProductMigrations]
AS
	SELECT 
		CalendarID, 
		TimeID, 
		SubscriptionID,
		CustomerID, 
		ProductFromID, 
		ProductToID, 
		IsUpgrade,
		IsDowngrade
	FROM factView.[ProductMigrations]
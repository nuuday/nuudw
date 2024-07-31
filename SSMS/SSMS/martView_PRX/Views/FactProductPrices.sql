

CREATE VIEW martView_PRX.[FactProductPrices] 
AS
SELECT
	[CalendarFromID]
	,[CalendarToID]
	,[ProductID]
	,[ActivationBasePriceInclTax]
	,[DeactivationBasePriceInclTax]
	,[MonthlyBasePriceInclTax]	
FROM [factView].[ProductPrices]
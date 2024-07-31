CREATE VIEW [factView].[ProductPrices] 
AS
SELECT
	[CalendarFromID]
	,[CalendarToID]
	,[ProductID]
	,[ActivationBasePriceInclTax]
	,[DeactivationBasePriceInclTax]
	,[MonthlyBasePriceInclTax]
	,[DWCreatedDate]
	,[DWModifiedDate]
	
FROM [fact].[ProductPrices]
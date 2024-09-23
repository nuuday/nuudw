
CREATE VIEW [martView_PRX].[DimQuote]
AS
SELECT 
	[QuoteID],
	[QuoteKey],
	[QuoteNumber],
	DWValidFromDate,
	DWValidToDate,
	DWIsCurrent,
	DWIsDeleted
FROM [dimView].[Quote]
CREATE VIEW [dimView].[Quote] 
AS
SELECT
	[QuoteID]
	,[QuoteKey] AS [QuoteKey]
	,[QuoteNumber] AS [QuoteNumber]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[Quote]
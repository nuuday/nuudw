CREATE VIEW [dimView].[Quote] 
AS
SELECT
	[QuoteID]
	,[QuoteKey] AS [QuoteKey]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[Quote]
CREATE VIEW [dimView].[Address] 
AS
SELECT
	[AddressID]
	,[AddressKey] AS [AddressKey]
	,[Street1] AS [Street1]
	,[Street2] AS [Street2]
	,[Postcode] AS [Postcode]
	,[City] AS [City]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[Address]
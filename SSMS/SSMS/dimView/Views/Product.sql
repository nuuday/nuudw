CREATE VIEW [dimView].[Product] 
AS
SELECT
	[ProductID]
	,[ProductKey] AS [Product Key]
	,[ProductName] AS [Product Name]
	,[ProductType] AS [Product Type]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[Product]
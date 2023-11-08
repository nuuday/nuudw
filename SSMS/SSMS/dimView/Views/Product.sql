CREATE VIEW [dimView].[Product] 
AS
SELECT
	[ProductID]
	,[ProductKey] AS [ProductKey]
	,[ProductName] AS [ProductName]
	,[ProductType] AS [ProductType]
	,[ProductWeight] AS [ProductWeight]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[Product]
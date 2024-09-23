
CREATE VIEW [martView_PRX].[DimProduct]
AS
SELECT 
	[ProductID],
	[ProductKey],
	[ProductName],
	[ProductType],
	[ProductWeight],
	DWValidFromDate,
	DWValidToDate,
	DWIsCurrent,
	DWIsDeleted
FROM [dimView].[Product]
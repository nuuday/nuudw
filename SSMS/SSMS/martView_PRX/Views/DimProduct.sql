
CREATE VIEW [martView_PRX].[DimProduct]
AS
SELECT 	[ProductID],	[ProductKey],	[ProductName],	[ProductType],	[ProductWeight]
FROM [dimView].[Product]
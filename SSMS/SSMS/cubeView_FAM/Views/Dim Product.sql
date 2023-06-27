CREATE VIEW cubeView_FAM.[Dim Product]
AS
SELECT 
	[Legacy_ProductID] AS [ProductID],
	[Legacy Product Key] AS [Product Key],
	[Product Name],
	[Product Type Name],
	[Product Type Updated],
	[Product Main Category Name],
	[Product Category Name],
	[Product Sub Category Name],
	[Product Sub Category Split Name],
	[Product Weight],
	[Product Brand Category Name],
	[Product Technology Name],
	[Product Group Code],
	[Product Group Name]
FROM [dimView].[Legacy Product]
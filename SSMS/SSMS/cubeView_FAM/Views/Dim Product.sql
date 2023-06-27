CREATE VIEW cubeView_FAM.[Dim Product]
AS
SELECT 
	[Legacy_ProductID],
	[Legacy Product Key],
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
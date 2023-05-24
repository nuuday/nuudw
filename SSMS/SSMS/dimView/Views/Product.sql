CREATE VIEW [dimView].[Product] AS
SELECT
 [ProductID]
,[ProductKey] AS [Product Key]
,[ProductNo] AS [Product No]
,[ProductName] AS [Product Name]
,[MainProduct] AS [Main Product]
,[ProductType] AS [Product Type]
,[AddonProduct] AS [Addon Product]
,[ProductIsCurrent] AS [Product Is Current]

  FROM [dim].[Product]
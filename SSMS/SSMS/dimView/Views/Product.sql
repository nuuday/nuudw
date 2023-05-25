CREATE VIEW [dimView].[Product] AS
SELECT
 [ProductID]
,[ProductKey] AS [Product Key]
,[ProductName] AS [Product Name]
,[ProductType] AS [Product Type]

  FROM [dim].[Product]
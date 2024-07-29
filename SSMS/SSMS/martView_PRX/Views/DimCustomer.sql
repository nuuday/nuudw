
CREATE VIEW [martView_PRX].[DimCustomer]
AS
SELECT 	[CustomerID],	[CustomerKey],	[CustomerNumber],	[CustomerName],	[CustomerSegment],	[CustomerStatus],	[CustomerMigrationSource],	[CustomerMigrationDate]
FROM [dimView].[Customer]
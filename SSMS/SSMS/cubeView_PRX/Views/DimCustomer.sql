
CREATE VIEW [cubeView_PRX].[DimCustomer]
AS
SELECT 	[CustomerID],	[CustomerKey],	[CustomerName],	[CustomerSegment],	[CustomerStatus]
FROM [dimView].[Customer]
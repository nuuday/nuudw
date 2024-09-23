
CREATE VIEW [martView_PRX].[DimCustomer]
AS
SELECT 
	[CustomerID],
	[CustomerKey],
	[CustomerNumber],
	[CustomerName],
	[CustomerSegment],
	[CustomerStatus],
	[CustomerMigrationSource],
	[CustomerMigrationDate],
	DWValidFromDate,
	DWValidToDate,
	DWIsCurrent,
	DWIsDeleted
FROM [dimView].[Customer]
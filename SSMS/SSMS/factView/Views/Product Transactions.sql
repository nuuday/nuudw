CREATE VIEW [factView].[Product Transactions] 
AS
SELECT
	[CalendarID]
	,[ProductID]
	,[CustomerID]
	,[ProductTransactionsQuantity]
	,[ProductTransactionsType]
	,[DWCreatedDate]
	,[DWModifiedDate]
	
FROM [fact].[ProductTransactions]
CREATE VIEW [FactView].[Product Transactions] AS
SELECT
[ProductTransactionsIdentifier]
,[CalendarID] 
,[ProductID] 
,[CustomerID] 
,[ProductTransactionsQuantity]
,[ProductTransactionsType]

  FROM [Fact].[ProductTransactions]
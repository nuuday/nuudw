CREATE VIEW [dimView].[Customer] AS
SELECT
 [CustomerID]
,[CustomerKey] AS [Customer Key]
,[CustomerNo] AS [Customer No]
,[CustomerName] AS [Customer Name]
,[CustomerSegment] AS [Customer Segment]
,[CustomerStatus] AS [Customer Status]

  FROM [dim].[Customer]
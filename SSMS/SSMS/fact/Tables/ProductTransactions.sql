CREATE TABLE [fact].[ProductTransactions] (
    [ProductTransactionsIdentifier] NVARCHAR (50) NULL,
    [CalendarID]                    INT           DEFAULT ((-1)) NOT NULL,
    [ProductID]                     INT           DEFAULT ((-1)) NOT NULL,
    [CustomerID]                    INT           DEFAULT ((-1)) NOT NULL,
    [ProductTransactionsQuantity]   INT           NULL,
    [ProductTransactionsType]       NVARCHAR (10) NULL,
    [DWCreatedDate]                 DATETIME      NOT NULL,
    [DWModifiedDate]                DATETIME      NOT NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ProductTransactions]
    ON [fact].[ProductTransactions];


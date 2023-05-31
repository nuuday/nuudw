CREATE TABLE [fact].[ProductTransactions_Temp] (
    [ProductTransactionsIdentifier] NVARCHAR (50) NULL,
    [CalendarID]                    INT           DEFAULT ((-1)) NOT NULL,
    [ProductID]                     INT           DEFAULT ((-1)) NOT NULL,
    [CustomerID]                    INT           DEFAULT ((-1)) NOT NULL,
    [ProductTransactionsQuantity]   INT           NULL,
    [ProductTransactionsType]       NVARCHAR (10) NULL,
    [DWCreatedDate]                 DATETIME2 (0) NOT NULL,
    [DWModifiedDate]                DATETIME2 (0) NOT NULL
);


CREATE TABLE [stage].[Fact:_ProductTransactions] (
    [ProductTransactionsIdentifier] NVARCHAR (50) NULL,
    [CalendarKey]                   DATE          NULL,
    [ProductKey]                    NVARCHAR (50) NULL,
    [CustomerKey]                   NVARCHAR (50) NULL,
    [ProductTransactionsQuantity]   INT           NOT NULL,
    [ProductTransactionsType]       NVARCHAR (10) NULL,
    [DWCreatedDate]                 DATETIME      NOT NULL
);


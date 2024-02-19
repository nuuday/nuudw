CREATE TABLE [stage].[Fact_ProductTransactions] (
    [ProductTransactionsIdentifier] NVARCHAR (64) NULL,
    [BillingAccountKey]             NVARCHAR (12) NULL,
    [SubscriptionKey]               NVARCHAR (36) NULL,
    [CalendarKey]                   DATE          NULL,
    [TimeKey]                       TIME (0)      NULL,
    [ProductKey]                    NVARCHAR (36) NULL,
    [CustomerKey]                   NVARCHAR (12) NULL,
    [AddressBillingKey]             NVARCHAR (50) NULL,
    [HouseHoldkey]                  NVARCHAR (36) NULL,
    [SalesChannelKey]               NVARCHAR (36) NULL,
    [TransactionStateKey]           NVARCHAR (1)  NULL,
    [QuoteKey]                      NVARCHAR (10) NULL,
    [ProductTransactionsQuantity]   INT           NOT NULL,
    [ProductChurnQuantity]          INT           NULL,
    [CalendarToKey]                 DATETIME2 (7) NULL,
    [TimeToKey]                     TIME (0)      NULL,
    [CalendarCommitmentToKey]       DATETIME2 (7) NULL,
    [TimeCommitmentToKey]           TIME (0)      NULL,
    [PhoneDetailkey]                NVARCHAR (20) NULL,
    [TLO]                           NVARCHAR (1)  NULL,
    [ProductParentKey]              NVARCHAR (36) NULL,
    [SubscriptionParentKey]         NVARCHAR (36) NULL,
    [RGU]                           NVARCHAR (1)  NULL,
    [CalendarRGUkey]                DATETIME2 (7) NULL,
    [CalendarRGUTokey]              DATETIME2 (7) NULL,
    [Migration]                     SMALLINT      NULL,
    [ProductUpgrade]                NVARCHAR (1)  NULL,
    [DWCreatedDate]                 DATETIME      NOT NULL
);










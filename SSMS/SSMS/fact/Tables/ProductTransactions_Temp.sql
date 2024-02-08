CREATE TABLE [fact].[ProductTransactions_Temp] (
    [ProductTransactionsIdentifier] NVARCHAR (64) NULL,
    [BillingAccountID]              INT           DEFAULT ((-1)) NOT NULL,
    [SubscriptionID]                INT           DEFAULT ((-1)) NOT NULL,
    [CalendarID]                    INT           DEFAULT ((-1)) NOT NULL,
    [TimeID]                        INT           DEFAULT ((-1)) NOT NULL,
    [ProductID]                     INT           DEFAULT ((-1)) NOT NULL,
    [CustomerID]                    INT           DEFAULT ((-1)) NOT NULL,
    [AddressBillingID]              INT           DEFAULT ((-1)) NOT NULL,
    [HouseHoldID]                   INT           DEFAULT ((-1)) NOT NULL,
    [SalesChannelID]                INT           DEFAULT ((-1)) NOT NULL,
    [TransactionStateID]            INT           DEFAULT ((-1)) NOT NULL,
    [QuoteID]                       INT           DEFAULT ((-1)) NOT NULL,
    [ProductTransactionsQuantity]   INT           NULL,
    [ProductChurnQuantity]          INT           NULL,
    [CalendarToID]                  INT           DEFAULT ((-1)) NOT NULL,
    [TimeToID]                      INT           DEFAULT ((-1)) NOT NULL,
    [CalendarCommitmentToID]        INT           DEFAULT ((-1)) NOT NULL,
    [TimeCommitmentToID]            INT           DEFAULT ((-1)) NOT NULL,
    [PhoneDetailID]                 INT           DEFAULT ((-1)) NOT NULL,
    [TLO]                           NVARCHAR (1)  NULL,
    [ProductParentID]               INT           DEFAULT ((-1)) NOT NULL,
    [SubscriptionParentID]          INT           DEFAULT ((-1)) NOT NULL,
    [RGU]                           NVARCHAR (1)  NULL,
    [CalendarRGUID]                 INT           DEFAULT ((-1)) NOT NULL,
    [CalendarRGUToID]               INT           DEFAULT ((-1)) NOT NULL,
    [Migration]                     NVARCHAR (2)  NULL,
    [ProductUpgrade]                NVARCHAR (1)  NULL,
    [DWCreatedDate]                 DATETIME2 (0) NOT NULL,
    [DWModifiedDate]                DATETIME2 (0) NOT NULL
);








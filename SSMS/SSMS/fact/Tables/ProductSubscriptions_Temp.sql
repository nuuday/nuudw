CREATE TABLE [fact].[ProductSubscriptions_Temp] (
    [CalendarFromID]                  INT           DEFAULT ((-1)) NOT NULL,
    [CalendarToID]                    INT           DEFAULT ((-1)) NOT NULL,
    [SubscriptionID]                  INT           DEFAULT ((-1)) NOT NULL,
    [ProductID]                       INT           DEFAULT ((-1)) NOT NULL,
    [CustomerID]                      INT           DEFAULT ((-1)) NOT NULL,
    [SalesChannelID]                  INT           DEFAULT ((-1)) NOT NULL,
    [AddressBillingID]                INT           DEFAULT ((-1)) NOT NULL,
    [BillingAccountID]                INT           DEFAULT ((-1)) NOT NULL,
    [PhoneDetailID]                   INT           DEFAULT ((-1)) NOT NULL,
    [TechnologyID]                    INT           DEFAULT ((-1)) NOT NULL,
    [EmployeeID]                      INT           DEFAULT ((-1)) NOT NULL,
    [QuoteID]                         INT           DEFAULT ((-1)) NOT NULL,
    [QuoteItemID]                     INT           DEFAULT ((-1)) NOT NULL,
    [CalendarPlannedID]               INT           DEFAULT ((-1)) NOT NULL,
    [CalendarActivatedID]             INT           DEFAULT ((-1)) NOT NULL,
    [CalendarCancelledID]             INT           DEFAULT ((-1)) NOT NULL,
    [CalendarDisconnectedPlannedID]   INT           DEFAULT ((-1)) NOT NULL,
    [CalendarDisconnectedExpectedID]  INT           DEFAULT ((-1)) NOT NULL,
    [CalendarDisconnectedCancelledID] INT           DEFAULT ((-1)) NOT NULL,
    [CalendarDisconnectedID]          INT           DEFAULT ((-1)) NOT NULL,
    [CalendarRGUFromID]               INT           DEFAULT ((-1)) NOT NULL,
    [CalendarRGUToID]                 INT           DEFAULT ((-1)) NOT NULL,
    [CalendarMigrationLegacyID]       INT           DEFAULT ((-1)) NOT NULL,
    [DWCreatedDate]                   DATETIME2 (0) NOT NULL,
    [DWModifiedDate]                  DATETIME2 (0) NOT NULL
);




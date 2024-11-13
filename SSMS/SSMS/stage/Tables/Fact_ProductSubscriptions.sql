CREATE TABLE [stage].[Fact_ProductSubscriptions] (
    [CalendarFromKey]                  DATE           NULL,
    [TimeFromKey]                      TIME (0)       NULL,
    [CalendarToKey]                    DATE           NULL,
    [TimeToKey]                        TIME (0)       NULL,
    [SubscriptionKey]                  NVARCHAR (36)  NULL,
    [ProductKey]                       NVARCHAR (36)  NULL,
    [CustomerKey]                      NVARCHAR (36)  NULL,
    [SalesChannelKey]                  NVARCHAR (36)  NULL,
    [AddressBillingKey]                NVARCHAR (300) NULL,
    [BillingAccountKey]                NVARCHAR (10)  NULL,
    [PhoneDetailKey]                   NVARCHAR (20)  NULL,
    [TechnologyKey]                    NVARCHAR (50)  NULL,
    [EmployeeKey]                      NVARCHAR (30)  NULL,
    [QuoteKey]                         NVARCHAR (36)  NULL,
    [QuoteItemKey]                     NVARCHAR (36)  NULL,
    [CalendarPlannedKey]               DATE           NULL,
    [CalendarActivatedKey]             DATE           NULL,
    [CalendarCancelledKey]             DATE           NULL,
    [CalendarDisconnectedPlannedKey]   DATE           NULL,
    [CalendarDisconnectedExpectedKey]  DATE           NULL,
    [CalendarDisconnectedCancelledKey] DATE           NULL,
    [CalendarDisconnectedKey]          DATE           NULL,
    [CalendarRGUFromKey]               DATE           NULL,
    [CalendarRGUToKey]                 DATE           NULL,
    [CalendarMigrationLegacyKey]       DATE           NULL,
    [DWCreatedDate]                    DATETIME2 (0)  DEFAULT (sysdatetime()) NULL
);






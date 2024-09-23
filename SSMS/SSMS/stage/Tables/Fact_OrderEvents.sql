CREATE TABLE [stage].[Fact_OrderEvents] (
    [CalendarKey]        DATE           NULL,
    [TimeKey]            TIME (0)       NULL,
    [ProductKey]         NVARCHAR (36)  NULL,
    [ProductParentKey]   NVARCHAR (36)  NULL,
    [ProductHardwareKey] NVARCHAR (36)  NULL,
    [CustomerKey]        NVARCHAR (36)  NULL,
    [SubscriptionKey]    NVARCHAR (36)  NULL,
    [QuoteKey]           NVARCHAR (36)  NULL,
    [QuoteItemKey]       NVARCHAR (36)  NULL,
    [OrderEventKey]      NVARCHAR (3)   NULL,
    [SalesChannelKey]    NVARCHAR (36)  NULL,
    [BillingAccountKey]  NVARCHAR (10)  NULL,
    [PhoneDetailKey]     NVARCHAR (20)  NULL,
    [AddressBillingKey]  NVARCHAR (300) NULL,
    [HouseHoldKey]       NVARCHAR (36)  NULL,
    [TechnologyKey]      NVARCHAR (50)  NULL,
    [EmployeeKey]        NVARCHAR (30)  NULL,
    [TicketKey]          NVARCHAR (36)  NULL,
    [ThirdPartyStoreKey] INT            NULL,
    [IsTLO]              INT            NULL,
    [Quantity]           INT            NULL
);


















GO



CREATE TABLE [stage].[Fact_OrderEvents] (
    [CalendarKey]       DATE            NULL,
    [TimeKey]           TIME (0)        NULL,
    [ProductKey]        NVARCHAR (36)   NULL,
    [ProductParentKey]  NVARCHAR (36)   NULL,
    [CustomerKey]       NVARCHAR (12)   NULL,
    [SubscriptionKey]   NVARCHAR (36)   NULL,
    [QuoteKey]          NVARCHAR (10)   NULL,
    [OrderEventKey]     NVARCHAR (3)    NULL,
    [SalesChannelKey]   NVARCHAR (36)   NULL,
    [BillingAccountKey] NVARCHAR (10)   NULL,
    [PhoneDetailKey]    NVARCHAR (20)   NULL,
    [AddressBillingKey] NVARCHAR (300)  NULL,
    [HouseHoldKey]      NVARCHAR (36)   NULL,
    [TechnologyKey]     NVARCHAR (50)   NULL,
    [IsTLO]             INT             NULL,
    [Quantity]          INT             NULL,
    [NetAmount]         DECIMAL (19, 4) NULL,
    [GrossAmount]       DECIMAL (19, 4) NULL,
    [DiscountAmount]    DECIMAL (19, 4) NULL,
    [DiscountPct]       DECIMAL (7, 4)  NULL
);




﻿CREATE TABLE [fact].[OrderEvents] (
    [CalendarID]               INT           DEFAULT ((-1)) NOT NULL,
    [TimeID]                   INT           DEFAULT ((-1)) NOT NULL,
    [ProductID]                INT           DEFAULT ((-1)) NOT NULL,
    [ProductParentID]          INT           DEFAULT ((-1)) NOT NULL,
    [ProductHardwareID]        INT           DEFAULT ((-1)) NOT NULL,
    [CustomerID]               INT           DEFAULT ((-1)) NOT NULL,
    [SubscriptionID]           INT           DEFAULT ((-1)) NOT NULL,
    [QuoteID]                  INT           DEFAULT ((-1)) NOT NULL,
    [QuoteItemID]              INT           DEFAULT ((-1)) NOT NULL,
    [OrderEventID]             INT           DEFAULT ((-1)) NOT NULL,
    [SalesChannelID]           INT           DEFAULT ((-1)) NOT NULL,
    [BillingAccountID]         INT           DEFAULT ((-1)) NOT NULL,
    [PhoneDetailID]            INT           DEFAULT ((-1)) NOT NULL,
    [AddressBillingID]         INT           DEFAULT ((-1)) NOT NULL,
    [HouseHoldID]              INT           DEFAULT ((-1)) NOT NULL,
    [TechnologyID]             INT           DEFAULT ((-1)) NOT NULL,
    [EmployeeID]               INT           DEFAULT ((-1)) NOT NULL,
    [TicketID]                 INT           DEFAULT ((-1)) NOT NULL,
    [ThirdPartyStoreID]        INT           DEFAULT ((-1)) NOT NULL,
    [IsTLO]                    INT           NULL,
    [Quantity]                 INT           NULL,
    [IndividualServiceUserID]  INT           DEFAULT ((-1)) NOT NULL,
    [IndividualBillReceiverID] INT           DEFAULT ((-1)) NOT NULL,
    [IndividualLegalOwnerID]   INT           DEFAULT ((-1)) NOT NULL,
    [DWCreatedDate]            DATETIME2 (0) NOT NULL,
    [DWModifiedDate]           DATETIME2 (0) NOT NULL
);
















GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_OrderEvents]
    ON [fact].[OrderEvents];
















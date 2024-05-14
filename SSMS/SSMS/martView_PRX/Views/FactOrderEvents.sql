﻿

CREATE VIEW [martView_PRX].[FactOrderEvents]
AS
SELECT 
	[CalendarID],
	[TimeID],
	[ProductID],
	[ProductParentID],
	[ProductHardwareID],
	[CustomerID],
	[SubscriptionID],
	[QuoteID],
	[OrderEventID],
	[SalesChannelID],
	[BillingAccountID],
	[PhoneDetailID],
	[AddressBillingID],
	[HouseHoldID],
	TechnologyID,
	EmployeeID,
	TicketID,
	[IsTLO],
	[Quantity],
	[NetAmount],
	[GrossAmount],
	[DiscountAmount],
	[DiscountPct]
FROM [factView].[OrderEvents]
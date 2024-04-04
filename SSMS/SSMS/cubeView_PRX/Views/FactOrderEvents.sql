CREATE VIEW [cubeView_PRX].[FactOrderEvents]
AS
SELECT 	[CalendarID],	[TimeID],	[ProductID],	[ProductParentID],	[CustomerID],	[SubscriptionID],	[QuoteID],	[OrderEventID],	[SalesChannelID],	[BillingAccountID],	[PhoneDetailID],	[AddressBillingID],	[HouseHoldID],	[IsTLO],	[Quantity],	[NetAmount],	[GrossAmount],	[DiscountAmount],	[DiscountPct]
FROM [factView].[OrderEvents]
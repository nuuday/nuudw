

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
	[QuoteItemID],
	[OrderEventID],
	[SalesChannelID],
	[BillingAccountID],
	[PhoneDetailID],
	[AddressBillingID],
	[HouseHoldID],
	[TechnologyID],
	[EmployeeID],
	[TicketID],
	[ThirdPartyStoreID],
	[IsTLO],
	[Quantity]
FROM [factView].[OrderEvents]
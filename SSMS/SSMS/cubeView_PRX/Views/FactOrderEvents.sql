



CREATE VIEW [cubeView_PRX].[FactOrderEvents]
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
	ThirdPartyStoreID,
	[IsTLO],
	[Quantity],
	[IndividualServiceUserID],
    [IndividualBillReceiverID],
    [IndividualLegalOwnerID]
FROM [factView].[OrderEvents]
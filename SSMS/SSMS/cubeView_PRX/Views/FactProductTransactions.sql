
CREATE VIEW [cubeView_PRX].[FactProductTransactions]
AS
SELECT 	[BillingAccountID],	[SubscriptionID],	[CalendarID],	[TimeID],	[ProductID],	[CustomerID],	[AddressBillingID],	[HouseHoldID],	[SalesChannelID],	[TransactionStateID],	[QuoteID],	[ProductTransactionsQuantity],	[ProductChurnQuantity],	[CalendarToID],	[TimeToID],	[CalendarCommitmentToID],	[TimeCommitmentToID],	[PhoneDetailID],	[TLO],	[ProductParentID],	[SubscriptionParentID],	[RGU],	[CalendarRGUID],	[CalendarRGUToID],	[Migration],	[ProductUpgrade]
FROM [factView].[ProductTransactions]
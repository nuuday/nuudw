
CREATE VIEW [cubeView_PRX].[FactProductTransactionsMerge]
AS
SELECT 	[BillingAccountID],	[SubscriptionID],	[CalendarID],	[TimeID],	[ProductID],	[CustomerID],	[AddressBillingID],	[HouseHoldID],	[SalesChannelID],	[TransactionStateID],	[ProductTransactionsQuantity],	[ProductChurnQuantity],	[CalendarToID],	[TimeToID],	[CalendarCommitmentToID],	[TimeCommitmentToID],	[PhoneDetailID],	[TLO],	[ProductParentID],	[SubscriptionParentID],	[RGU],	[CalendarRGUID],	[CalendarRGUToID],	[Migration],	[ProductUpgrade]
FROM [factView].[ProductTransactionsMerge]
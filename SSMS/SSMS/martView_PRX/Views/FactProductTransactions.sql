
CREATE VIEW [martView_PRX].[FactProductTransactions]
AS
SELECT 	[CalendarID],	[TimeID],	[ProductID],	[CustomerID],	[AddressBillingID],	[HouseHoldID],	[SalesChannelID],	[TransactionStateID],	[ProductTransactionsQuantity],	[ProductChurnQuantity],	[CalendarToID],	[TimeToID],	[CalendarCommitmentToID],	[TimeCommitmentToID],	[PhoneDetailID],	[TLO],	[ProductParentID],	[RGU],	[Migration],	[ProductUpgrade]
FROM [factView].[ProductTransactions]




CREATE VIEW [martView_PRX].[FactProductSubscriptions] 
AS
SELECT
	[CalendarFromID]
	,TimeFromID
	,[CalendarToID]
	,TimeToID
	,[SubscriptionID]
	,[ProductID]
	,[CustomerID]
	,[SalesChannelID]
	,[AddressBillingID]
	,[BillingAccountID]
	,[PhoneDetailID]
	,[TechnologyID]
	,[EmployeeID]
	,[QuoteID]
	,[QuoteItemID]
	,[CalendarPlannedID]
	,[CalendarActivatedID]
	,[CalendarCancelledID]
	,[CalendarDisconnectedPlannedID]
	,[CalendarDisconnectedExpectedID]
	,[CalendarDisconnectedCancelledID]
	,[CalendarDisconnectedID]
	,[CalendarRGUFromID]
	,[CalendarRGUToID]
	,[CalendarMigrationLegacyID]	
FROM [factView].[ProductSubscriptions]
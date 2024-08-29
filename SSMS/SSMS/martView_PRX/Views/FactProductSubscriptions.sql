﻿

CREATE VIEW [martView_PRX].[FactProductSubscriptions] 
AS
SELECT
	[CalendarFromID]
	,[CalendarToID]
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
	,[CalendarDisconnectedPlannedID]
	,[CalendarDisconnectedExpectedID]
	,[CalendarDisconnectedCancelledID]
	,[CalendarDisconnectedID]
	,[CalendarRGUFromID]
	,[CalendarRGUToID]
	,[CalendarMigrationLegacyID]	
FROM [factView].[ProductSubscriptions]
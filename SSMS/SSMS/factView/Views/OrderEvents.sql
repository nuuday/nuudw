﻿
CREATE VIEW [factView].[OrderEvents] 
AS
SELECT
	[CalendarID]
	,[TimeID]
	,[ProductID]
	,[ProductParentID]
	,[ProductHardwareID]
	,[CustomerID]
	,[SubscriptionID]
	,[QuoteID]
	,[QuoteItemID]
	,[OrderEventID]
	,[SalesChannelID]
	,[BillingAccountID]
	,[PhoneDetailID]
	,[AddressBillingID]
	,[HouseHoldID]
	,[TechnologyID]
	,[EmployeeID]
	,[TicketID]
	,[ThirdPartyStoreID]
	,[IsTLO]
	,[Quantity]
	,[DWCreatedDate]
	,[DWModifiedDate]
	
FROM [fact].[OrderEvents]
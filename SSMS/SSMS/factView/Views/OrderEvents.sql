﻿CREATE VIEW [factView].[OrderEvents] 
AS
SELECT
	[CalendarID]
	,[TimeID]
	,[ProductID]
	,[ProductParentID]
	,[CustomerID]
	,[SubscriptionID]
	,[QuoteID]
	,[OrderEventID]
	,[SalesChannelID]
	,[BillingAccountID]
	,[PhoneDetailID]
	,[AddressBillingID]
	,[HouseHoldID]
	,[IsTLO]
	,[Quantity]
	,[NetAmount]
	,[GrossAmount]
	,[DiscountAmount]
	,[DiscountPct]
	,[DWCreatedDate]
	,[DWModifiedDate]
	
FROM [fact].[OrderEvents]
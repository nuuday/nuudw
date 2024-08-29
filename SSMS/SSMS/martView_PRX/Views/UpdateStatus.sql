
CREATE VIEW [martView_PRX].[UpdateStatus]
AS

SELECT *
FROM (
	SELECT 'martView_PRX.DimCustomer' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM dim.Customer UNION ALL
	SELECT 'martView_PRX.DimProduct' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM dim.Product UNION ALL
	SELECT 'martView_PRX.DimSalesChannel' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM dim.SalesChannel UNION ALL
	SELECT 'martView_PRX.DimCalendar' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM dim.Calendar UNION ALL
	SELECT 'martView_PRX.DimAddress' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM dim.Address UNION ALL
	SELECT 'martView_PRX.DimPhoneDetail' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM dim.PhoneDetail UNION ALL
	SELECT 'martView_PRX.DimHouseHold' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM dim.HouseHold UNION ALL
	SELECT 'martView_PRX.DimSubscription' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM dim.Subscription UNION ALL
	SELECT 'martView_PRX.DimBillingAccount' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM dim.BillingAccount UNION ALL
	SELECT 'martView_PRX.DimQuote' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM dim.Quote UNION ALL
	SELECT 'martView_PRX.DimOrderEvent' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM dim.OrderEvent UNION ALL
	SELECT 'martView_PRX.FactOrderEvents' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM fact.OrderEvents UNION ALL
	SELECT 'martView_PRX.DimEmployee' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM dim.Employee UNION ALL
	SELECT 'martView_PRX.DimTechnology' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM dim.Technology UNION ALL
	SELECT 'martView_PRX.DimTicket' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM dim.Ticket UNION ALL
	SELECT 'martView_PRX.DimThirdPartyStore' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM dim.ThirdPartyStore UNION ALL
	SELECT 'martView_PRX.DimQuoteItem' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM dim.QuoteItem UNION ALL
	SELECT 'martView_PRX.FactProductPrices' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM fact.ProductPrices  UNION ALL
	SELECT 'martView_PRX.FactProductSubscriptions' TableName,  MAX(DWModifiedDate) DWModifiedDate FROM fact.ProductSubscriptions 
) q
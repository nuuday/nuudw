
CREATE VIEW [martView_PRX].[DimSalesChannel]
AS
SELECT 
	[SalesChannelID],
	[SalesChannelKey],
	[SalesChannelName],
	[SalesChannelLongName],
	[SalesChannelType],
	[InsurancePolicy],
	[StoreAddress],
	[StoreNumber],
	[StoreName],
	DWValidFromDate,
	DWValidToDate,
	DWIsCurrent,
	DWIsDeleted
FROM [dimView].[SalesChannel]
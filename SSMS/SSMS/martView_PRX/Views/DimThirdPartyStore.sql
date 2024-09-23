
CREATE VIEW [martView_PRX].[DimThirdPartyStore]
AS
SELECT 
	[ThirdPartyStoreID],
	[ThirdPartyStoreKey],
	[StoreID],
	[StoreName],
	DWValidFromDate,
	DWValidToDate,
	DWIsCurrent,
	DWIsDeleted
FROM [dimView].[ThirdPartyStore]
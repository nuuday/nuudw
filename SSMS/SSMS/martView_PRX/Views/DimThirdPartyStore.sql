
CREATE VIEW [martView_PRX].[DimThirdPartyStore]
AS
SELECT 
	[ThirdPartyStoreID],
	[ThirdPartyStoreKey],
	[StoreID],
	[StoreName]
FROM [dimView].[ThirdPartyStore]
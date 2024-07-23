CREATE VIEW [dimView].[ThirdPartyStore] 
AS
SELECT
	[ThirdPartyStoreID]
	,[ThirdPartyStoreKey] AS [ThirdPartyStoreKey]
	,[StoreID]
	,[StoreName] AS [StoreName]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[ThirdPartyStore]
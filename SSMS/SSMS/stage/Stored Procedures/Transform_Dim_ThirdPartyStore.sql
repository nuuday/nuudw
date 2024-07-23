
CREATE PROCEDURE [stage].[Transform_Dim_ThirdPartyStore]
	@JobIsIncremental BIT			
AS 


TRUNCATE TABLE [stage].[Dim_ThirdPartyStore]
INSERT INTO stage.[Dim_ThirdPartyStore] WITH (TABLOCK) (ThirdPartyStoreKey, StoreID, StoreName)
SELECT
	YouSeeStoreID AS ThirdPartyStoreKey,
	StoreID,
	StoreName	
FROM masterdata.ThirdPartyStores
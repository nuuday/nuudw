
CREATE PROCEDURE [stage].[Transform_Dim_ThirdPartyStore]
	@JobIsIncremental BIT			
AS 


TRUNCATE TABLE [stage].[Dim_ThirdPartyStore]

;WITH stores AS (

	SELECT
		*,
		ROW_NUMBER() OVER (PARTITION BY q.ThirdPartyStoreKey ORDER BY q.ranking) rn
	FROM (
		SELECT
			YouSeeStoreID AS ThirdPartyStoreKey,
			StoreID,
			StoreName,
			1 as ranking
		FROM masterdata.ThirdPartyStores
		UNION 
		SELECT DISTINCT
			JSON_VALUE(q.extended_parameters, '$."3rdPartyStoreId"[0]') ThirdPartyStoreId,
			0 StoreID,
			'?' StoreName,
			2 ranking
		FROM [sourceNuudlDawnView].[qssnrmlquote_History] q
		WHERE JSON_VALUE(q.extended_parameters, '$."3rdPartyStoreId"[0]') IS NOT NULL
		) q
)


INSERT INTO stage.[Dim_ThirdPartyStore] WITH (TABLOCK) (ThirdPartyStoreKey, StoreID, StoreName)
SELECT ThirdPartyStoreKey, StoreID, StoreName
FROM stores
WHERE rn=1

CREATE PROCEDURE [stage].[Transform_Product] 


			
AS 
		
/**********************************************************************************************************************************************************************
1. Truncate Table
***********************************************************************************************************************************************************************/

TRUNCATE TABLE [stage].[Product]

/**********************************************************************************************************************************************************************
2. Business Logik - Remember to use the input variable @JobIsIncremental to distinguish between full and incremental load. 
***********************************************************************************************************************************************************************/

/*Full Load pattern*/

	INSERT INTO stage.[Product] WITH (TABLOCK)
	  ([ProductKey]
      ,[ProductNo]
      ,[ProductName]
	  ,[MainProduct]
	  ,[ProductType]
	  ,[AddonProduct]
	  ,[ProductIsCurrent]
	  ,[DWCreatedDate])

	--Apply business logic for full load here

/**********************************************************************************************************************************************************************
3. SELECT column and values, matching the namingconvention and standard for values, when it contains "Null".
   SCD Type 2 is excluded.
***********************************************************************************************************************************************************************/
SELECT DISTINCT
	   product.[id]										    AS ProductKey
	  ,NULL												    AS ProductNo
	  ,product.[name]									    AS ProductName
	  ,productoffering.[MainProduct]					    AS MainProduct
	  ,family.[name]									    AS ProductType
	  ,NULL													AS AddonProduct
	  ,[is_active]											AS ProductIsCurrent
	  ,Getdate()											AS DWCreatedDate
FROM [sourceDataLakeNetcracker_interim].[product_offering] product

LEFT JOIN [sourceDataLakeNetcracker_interim].[product_family] family
ON product.product_family_id = family.id

	-- Subquery in Join selects MainProduct from product_offering
LEFT JOIN (
			SELECT
			 [id] 
		    ,[name] AS MainProduct
			FROM [sourceDataLakeNetcracker_interim].[product_offering-template]
			WHERE is_saleable_stand_alone = 1
			AND is_one_time_offering = 0
			AND v_deleted_timestamp IS NULL
		  ) productoffering ON
			product.id = productoffering.id
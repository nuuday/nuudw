
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
      ,[ProductName]
	  ,[ProductType])

	--Apply business logic for full load here

/**********************************************************************************************************************************************************************
3. SELECT column and values, matching the namingconvention and standard for values, when it contains "Null".
   SCD Type 2 is excluded.
***********************************************************************************************************************************************************************/
SELECT DISTINCT
	   p.[id]	 AS ProductKey
	  ,p.[name]	 AS ProductName
	  ,pf.[name] AS ProductType
FROM [sourceDataLakeNetcracker_interim].[product_offering] p

LEFT JOIN [sourceDataLakeNetcracker_interim].[product_family] pf
ON p.product_family_id = pf.id
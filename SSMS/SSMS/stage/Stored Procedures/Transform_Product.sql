
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
	  ,[ProductType]
	  ,[DWCreatedDate])

	--Apply business logic for full load here

/**********************************************************************************************************************************************************************
3. SELECT column and values, matching the namingconvention and standard for values, when it contains "Null".
   SCD Type 2 is excluded.
***********************************************************************************************************************************************************************/
SELECT 
	   CONVERT(NVARCHAR(50), p.[id])								AS ProductKey
	  ,CONVERT(NVARCHAR(250), ISNULL(NULLIF(p.[name], ''), '?'))	AS ProductName
	  ,CONVERT(NVARCHAR(50), ISNULL(NULLIF(pf.[name], ''), '?'))	AS ProductType
	  ,GETDATE()													AS DWCreatedDate
	  --INTO stage.Product 
FROM [sourceDataLakeNetcracker_interim].[product_offering] p

LEFT JOIN [sourceDataLakeNetcracker_interim].[product_family] pf
ON p.product_family_id = pf.id
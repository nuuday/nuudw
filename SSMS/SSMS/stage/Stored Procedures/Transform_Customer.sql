
CREATE PROCEDURE [stage].[Transform_Customer] 


			
AS 
		
/**********************************************************************************************************************************************************************
1. Truncate Table
***********************************************************************************************************************************************************************/

TRUNCATE TABLE [stage].[Customer]

/**********************************************************************************************************************************************************************
2. Business Logik - Remember to use the input variable @JobIsIncremental to distinguish between full and incremental load. 
***********************************************************************************************************************************************************************/

/*Full Load pattern*/

	INSERT INTO stage.[Customer] WITH (TABLOCK)
	  ([CustomerKey]
      ,[CustomerNo]
      ,[CustomerName]
	  ,[CustomerSegment]
	  ,[CustomerStatus]
	  ,[CustomerIsCurrent]
	  ,[DWCreatedDate])

	--Apply business logic for full load here

/**********************************************************************************************************************************************************************
3. SELECT column and values, matching the namingconvention and standard for values, when it contains "Null".
   SCD Type 2 is excluded.
***********************************************************************************************************************************************************************/
SELECT DISTINCT
	   customer.[id]														      AS CustomerKey
      ,[customer_number]													      AS CustomerNo
      ,CASE WHEN customer.[name]   IS NULL    THEN '?' ELSE customer.[name]   END AS CustomerName				
	  ,customer_category.[name]												      AS CustomerSegment
	  ,CASE WHEN customer.[status] IS NULL    THEN '?' ELSE customer.[status] END AS CustomerStatus
	  ,CASE WHEN customer.[status] = 'Active' THEN 1 ELSE 0				      END AS CustomerIsCurrent
	  ,Getdate()												                  AS DWCreatedDate

	-- Subquery to SELECT Active and Prospect customers without duplicates on CustomerKey
FROM 
	(
   		SELECT id, active_from, active_to, customer_number, [name], [status], customer_category_id
   		,ROW_NUMBER() OVER (PARTITION BY id ORDER BY ISNULL(active_to, '9999-12-31') DESC) rn
   		FROM [sourceDataLakeNetcracker_interim].[customer]
	) customer

	LEFT JOIN sourceDataLakeNetcracker_interim.customer_category customer_category
	ON customer_category.id = customer.customer_category_id

	WHERE customer.rn = 1
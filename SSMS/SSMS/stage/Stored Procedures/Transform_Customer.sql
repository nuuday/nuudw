
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
	  ,[DWCreatedDate])

	--Apply business logic for full load here

/**********************************************************************************************************************************************************************
3. SELECT column and values, matching the namingconvention and standard for values, when it contains "Null".
   SCD Type 2 is excluded.
***********************************************************************************************************************************************************************/
	  SELECT 
	   CONVERT(NVARCHAR(50), customer.[id])											AS CustomerKey
      ,CONVERT(NVARCHAR(50), [customer_number])										AS CustomerNo
      ,CONVERT(NVARCHAR(250), ISNULL(NULLIF(customer.[name], ''), '?'))				AS CustomerName				
	  ,CONVERT(NVARCHAR(50), ISNULL(NULLIF(customer_category.[name], ''), '?')) 	AS CustomerSegment
	  ,CONVERT(NVARCHAR(20), ISNULL(NULLIF(customer.[status], ''), '?'))			AS CustomerStatus
	  ,GETDATE()																	AS DWCreatedDate

	-- Subquery to SELECT Active and Prospect customers without duplicates on CustomerKey
	/* Decide to use Type 2 or not. If yes, what specific columns should include Type 2 history */ 
	FROM 
		(
   			SELECT id, active_from, active_to, customer_number, [name], [status], customer_category_id
   			,ROW_NUMBER() OVER (PARTITION BY id ORDER BY ISNULL(active_to, '9999-12-31') DESC) rn 
			/* Using the most recenct customer record for now untill decision on Type 2 history */
   			FROM [sourceDataLakeNetcracker_interim].[customer]
		) customer

	LEFT JOIN sourceDataLakeNetcracker_interim.customer_category customer_category
	ON customer_category.id = customer.customer_category_id

	WHERE customer.rn = 1 --Remove if type 2 history 
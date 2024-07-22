
CREATE PROCEDURE [stage].[Transform_Dim_Customer]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_Customer]

INSERT INTO stage.[Dim_Customer] WITH (TABLOCK) ( [CustomerKey],[CustomerName], [CustomerSegment], [CustomerStatus] )
SELECT 
	CONVERT( NVARCHAR(12), customer.[customer_number] ) AS CustomerKey,
	CONVERT( NVARCHAR(250), ISNULL( NULLIF( customer.[name], '' ), '?' ) ) AS CustomerName,
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( customer_category.[name], '' ), '?' ) ) AS CustomerSegment,
	CONVERT( NVARCHAR(20), ISNULL( NULLIF( customer.[status], '' ), '?' ) ) AS CustomerStatus
FROM [sourceNuudlDawnView].[cimcustomer_History] customer
LEFT JOIN [sourceNuudlNetCrackerView].[pimnrmlcustomercategory_History] customer_category
	ON customer_category.id = customer.customer_category_id
WHERE
	customer.NUUDL_IsCurrent = 1
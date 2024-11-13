
CREATE PROCEDURE [stage].[Transform_Dim_Customer]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_Customer]

INSERT INTO stage.[Dim_Customer] WITH (TABLOCK) ( [CustomerKey], [CustomerNumber], [CustomerName], [CustomerSegment], [CustomerStatus], CustomerMigrationDate, CustomerMigrationSource )
SELECT 
	CONVERT( NVARCHAR(36), customer.id ) AS CustomerKey,
	CONVERT( NVARCHAR(36), customer.customer_number ) AS CustomerNumber,
	CONVERT( NVARCHAR(250), ISNULL( NULLIF( customer.[name], '' ), '?' ) ) AS CustomerName,
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( customer_category.[name], '' ), '?' ) ) AS CustomerSegment,
	CONVERT( NVARCHAR(20), ISNULL( NULLIF( customer.[status], '' ), '?' ) ) AS CustomerStatus,
	ISNULL(JSON_VALUE(customer.extended_attributes,'$.migration_date[0]'),'1900-01-01') CustomerMigrationDate,
	ISNULL(JSON_VALUE(customer.extended_attributes,'$.migration_source[0]'), '?' ) CustomerMigrationSource
FROM [sourceNuudlDawnView].[cimcustomer_History] customer
LEFT JOIN [sourceNuudlNetCrackerView].[pimnrmlcustomercategory_History] customer_category
	ON customer_category.id = customer.customer_category_id
WHERE
	customer.NUUDL_IsLatest =1
	--AND customer.customer_number='70004697884'
	--and customer.id= '873b84f2-6c82-4f91-a98e-40810f4f8571'
group by  CONVERT( NVARCHAR(36), customer.id ), 
	CONVERT( NVARCHAR(36), customer.customer_number ),
	CONVERT( NVARCHAR(250), ISNULL( NULLIF( customer.[name], '' ), '?' ) ) ,
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( customer_category.[name], '' ), '?' ) ),
	CONVERT( NVARCHAR(20), ISNULL( NULLIF( customer.[status], '' ), '?' ) ) ,
	ISNULL(JSON_VALUE(customer.extended_attributes,'$.migration_date[0]'),'1900-01-01'),
	ISNULL(JSON_VALUE(customer.extended_attributes,'$.migration_source[0]'), '?' )
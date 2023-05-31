
CREATE PROCEDURE [stage].[Transform_Dim_Customer]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_Customer]

INSERT INTO stage.[Dim_Customer] WITH (TABLOCK) ( [CustomerKey], [CustomerNo], [CustomerName], [CustomerSegment], [CustomerStatus], [DWCreatedDate] )
SELECT
	CONVERT( NVARCHAR(50), customer.[ID] ) AS CustomerKey,
	CONVERT( NVARCHAR(50), [customer_number] ) AS CustomerNo,
	CONVERT( NVARCHAR(250), ISNULL( NULLIF( customer.[name], '' ), '?' ) ) AS CustomerName,
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( customer_category.[name], '' ), '?' ) ) AS CustomerSegment,
	CONVERT( NVARCHAR(20), ISNULL( NULLIF( customer.[status], '' ), '?' ) ) AS CustomerStatus,
	GETDATE() AS DWCreatedDate

-- Subquery to SELECT Active and Prospect customers without duplicates on CustomerKey
/* Decide to use Type 2 or not. If yes, what specific columns should include Type 2 history */
FROM (
	SELECT
		ID,
		active_from,
		active_to,
		customer_number,
		[name],
		[status],
		customer_category_id,
		ROW_NUMBER() OVER (PARTITION BY ID ORDER BY ISNULL( active_to, '9999-12-31' ) DESC) rn
	/* Using the most recenct customer record for now untill decision on Type 2 history */
	FROM [sourceDataLakeNetcracker_interim].[customer]
) customer

LEFT JOIN sourceDataLakeNetcracker_interim.customer_category customer_category
	ON customer_category.ID = customer.customer_category_id

WHERE
	customer.rn = 1 --Remove if type 2 history 
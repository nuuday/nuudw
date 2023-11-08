
CREATE PROCEDURE [stage].[Transform_Dim_Customer]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_Customer]

INSERT INTO stage.[Dim_Customer] WITH (TABLOCK) ( [CustomerKey],[CustomerName], [CustomerSegment], [CustomerStatus],[PartyRoleType], [DWCreatedDate] )


SELECT 
	CONVERT( NVARCHAR(12), customer.[customer_number] ) AS CustomerKey,
	CONVERT( NVARCHAR(250), ISNULL( NULLIF( customer.[name], '' ), '?' ) ) AS CustomerName,
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( customer_category.[name], '' ), '?' ) ) AS CustomerSegment,
	CONVERT( NVARCHAR(20), ISNULL( NULLIF( customer.[status], '' ), '?' ) ) AS CustomerStatus,
	CONVERT( NVARCHAR(20), ISNULL( NULLIF( p.party_role_type, '' ), '?' ) ) AS PartyRoleType,
	GETDATE() AS DWCreatedDate

-- Subquery to SELECT Active and Prospect customers without duplicates on CustomerKey

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
	FROM [sourceNuudlNetCrackerView].[cimcustomer_History] 
) customer

LEFT JOIN [sourceNuudlNetCrackerView].[pimnrmlcustomercategory_History]  customer_category
	ON customer_category.ID = customer.customer_category_id
	
 LEFT JOIN (select * from (
select 
id,id_to,id_from,
ROW_NUMBER() OVER (PARTITION BY id_to ORDER BY ISNULL( active_from, '9999-12-31' ) DESC) rn
from [sourceNuudlNetCrackerView].[cimpartyroleassociation_History]
where  is_current=1
) ab where rn=1
 )ac ON ac.id_to = customer.id 

 LEFT JOIN [sourceNuudlNetCrackerView].[cimpartyrole_History] p ON
	p.id = ac.id_from and p.is_current=1

	where customer.rn =1
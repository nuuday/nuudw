
CREATE PROCEDURE [stage].[Transform_Dim_Product]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_Product]

INSERT INTO stage.[Dim_Product] WITH (TABLOCK) ( [ProductKey], [ProductName], [ProductType],[ProductWeight],[DWCreatedDate] )
SELECT
	CONVERT( NVARCHAR(36), p.[id] ) AS ProductKey,
	CONVERT( NVARCHAR(250), ISNULL( NULLIF( p.[name], '' ), '?' ) ) AS ProductName,
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( pf.[name], '' ), '?' ) ) AS ProductType,  
	CONVERT( NVARCHAR(3), p.weight)  AS ProductWeight, 
	GETDATE() AS DWCreatedDate

FROM [sourceNuudlNetCrackerView].[pimnrmlproductoffering_History] p

LEFT JOIN [sourceNuudlNetCrackerView].[pimnrmlproductfamily_History] pf
	ON p.product_family_id = pf.id
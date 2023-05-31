
CREATE PROCEDURE [stage].[Transform_Dim_Product]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_Product]

INSERT INTO stage.[Product] WITH (TABLOCK) ( [ProductKey], [ProductName], [ProductType], [DWCreatedDate] )
SELECT
	CONVERT( NVARCHAR(50), p.[id] ) AS ProductKey,
	CONVERT( NVARCHAR(250), ISNULL( NULLIF( p.[name], '' ), '?' ) ) AS ProductName,
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( pf.[name], '' ), '?' ) ) AS ProductType,
	GETDATE() AS DWCreatedDate
--INTO stage.Product 
FROM [sourceDataLakeNetcracker_interim].[product_offering] p

LEFT JOIN [sourceDataLakeNetcracker_interim].[product_family] pf
	ON p.product_family_id = pf.id
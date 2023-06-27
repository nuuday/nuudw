
CREATE PROCEDURE [stage].[Transform_Dim_Legacy_Product]
	@JobIsIncremental BIT			
AS 

/*
DECLARE @JobIsIncremental BIT = 0
--*/

TRUNCATE TABLE [stage].[Dim_Legacy_Product]

DECLARE @LastModifiedDate DATETIME2(7) = '1900-01-01';

IF @JobIsIncremental = 1    -- Incremental
BEGIN
	SET @LastModifiedDate = (SELECT ISNULL(MAX(DWModifiedDate) ,@LastModifiedDate) FROM dim.Legacy_Product WHERE Legacy_ProductID <> -1);
END

INSERT INTO [stage].[Dim_Legacy_Product] WITH (TABLOCK) ( [Legacy_ProductKey], [ProductName], [ProductTypeName],  [ProductMainCategoryName], [ProductCategoryName], [ProductSubCategoryName], [ProductSubCategorySplitName], [ProductWeight], [ProductBrandCategoryName], [ProductTechnologyName], [Legacy_ProductIsCurrent], [Legacy_ProductValidFromDate], [Legacy_ProductValidToDate], [ProductGroupCode], [ProductGroupName], [DWCreatedDate] )
SELECT DISTINCT
	[ProductID] AS [ProductKey],
	[ProductName] AS [ProductName],
	[ProductType] AS [ProductTypeName],
	[ProductMainCategory] AS [ProductMainCategoryName],
	[ProductCategory] AS [ProductCategoryName],
	[ProductSubCategory] AS [ProductSubCategoryName],
	[ProductSubCategory2] AS [ProductSubCategorySplitName],
	[ProductWeight] AS [ProductWeight],
	(CASE
		WHEN [ProductBrandCategory] = 'NA' THEN '?'
		ELSE [ProductBrandCategory]
	END) AS [ProductBrandCategoryName],
	(CASE
		WHEN [Technology] = 'NA' THEN '?'
		ELSE [Technology]
	END) AS [ProductTechnologyName],
	pro.DWIsCurrent AS [Legacy_ProductIsCurrent],
	pro.DWValidFromDate AS [Legacy_ProductValidFromDate],
	pro.DWValidToDate AS [Legacy_ProductValidToDate],
	CASE
		WHEN [ProductCategory] IN ('MOBIL TELEFONI') AND [ProductSubCategory] NOT LIKE 'Mobil Telefoni Øvrige' AND [ProductType] = 'Main Product' THEN 'MV'
		WHEN [ProductCategory] IN ('MOBIL BREDBÅND') AND [ProductType] = 'Main Product' THEN 'MBB'
		WHEN [ProductCategory] IN ('FLOW', 'KABEL-TV', 'TDC TV', 'COAX', 'TV TEKNOLOGI FLEX') AND [ProductType] = 'Main Product' THEN 'TV'
		WHEN [ProductCategory] IN ('BREDBÅND', 'FASTNET BREDBÅND') AND [ProductType] = 'Main Product'
		AND ProductID NOT BETWEEN 'C0011350001' AND 'C0011350015' THEN 'BB'
		WHEN [ProductCategory] IN ('Fastnet Telefoni - ISDN', 'Fastnet Telefoni - PSTN') AND [ProductType] = 'Main Product' THEN 'PSTN'
		WHEN [ProductSubCategory] IN ('Medium packages, Teknologi Flex', 'Full packages, Teknologi Flex') AND [ProductType] = 'Add On Product' AND [ProductName] NOT LIKE '%KODA%' THEN 'TVT'
		WHEN [ProductSubCategory] IN ('Medium packages', 'Full packages') AND [ProductType] = 'Add On Product' AND [ProductName] NOT LIKE '%KODA%' THEN 'TVT'
		ELSE 'NONE'
	END AS [ProductGroupCode],
	CASE
		WHEN [ProductCategory] IN ('MOBIL TELEFONI') AND [ProductSubCategory] NOT LIKE 'Mobil Telefoni Øvrige' AND [ProductType] = 'Main Product' THEN 'Mobil Telefoni'
		WHEN [ProductCategory] IN ('MOBIL BREDBÅND') AND [ProductType] = 'Main Product' THEN 'Mobil Bredbånd'
		WHEN [ProductCategory] IN ('FLOW', 'KABEL-TV', 'TDC TV', 'COAX', 'TV TEKNOLOGI FLEX') AND [ProductType] = 'Main Product' THEN 'TV Pakker'
		WHEN [ProductCategory] IN ('BREDBÅND', 'FASTNET BREDBÅND') AND [ProductType] = 'Main Product'
		AND ProductID NOT BETWEEN 'C0011350001' AND 'C0011350015' THEN 'Bredbånd'
		WHEN [ProductCategory] IN ('Fastnet Telefoni - ISDN', 'Fastnet Telefoni - PSTN') AND [ProductType] = 'Main Product' THEN 'Fastnet Telefoni'
		WHEN [ProductSubCategory] IN ('Medium packages, Teknologi Flex', 'Full packages, Teknologi Flex') AND [ProductType] = 'Add On Product' AND [ProductName] NOT LIKE '%KODA%' THEN 'TV Tillægspakker og bland selv'
		WHEN [ProductSubCategory] IN ('Medium packages', 'Full packages') AND [ProductType] = 'Add On Product' AND [ProductName] NOT LIKE '%KODA%' THEN 'TV Tillægspakker og bland selv'
		ELSE 'Ikke i Produktgruppe'
	END AS [ProductGroupName],
	GETDATE() AS [DWCreatedDate]
FROM SourceNuudlBIZView.DimProduct_History pro
WHERE
	(ProductID NOT IN ('No product', 'Internal', 'No changes', 'Not part of bundle', 'External'))
	AND SourceSystem IN ('CU', 'DF', 'FP', 'NABS', 'NM', 'CS', 'MB', 'SF')
	AND pro.DWModifiedDate > @LastModifiedDate
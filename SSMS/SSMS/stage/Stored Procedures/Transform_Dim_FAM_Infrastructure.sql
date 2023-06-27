
CREATE PROCEDURE [stage].[Transform_Dim_FAM_Infrastructure]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_FAM_Infrastructure]


DROP TABLE IF EXISTS #LowerCase
SELECT
		ProductName AS InfrastructureKey
		,CASE WHEN ProductName LIKE '%INFRASTRUKTUR' THEN LOWER(LEFT(ProductName, charindex(' ', ProductName) - 1))
				WHEN ProductName LIKE '%TF FIBER%'     THEN 'Ewii' ELSE LOWER(ProductName) END AS InfrastructureName
INTO #LowerCase
FROM SourceNuudlBIZView.DimProduct_History
WHERE 1 = 1
AND ProductID IN ('C0010766087', 'C0010766866', 'C0010766865', 'C0010766864', 'C0010766868', 'C0010766869', 'C0010766879', 'C0010766867')

INSERT INTO stage.[Dim_FAM_Infrastructure] WITH (TABLOCK) ( FAM_Infrastructurekey, InfrastructureName, DWCreatedDate )
SELECT
	InfrastructureKey AS FAM_InfrastructureKey,
	CASE
		WHEN InfrastructureName = 'tdc' THEN 'TDC'
		ELSE UPPER( LEFT( InfrastructureName, 1 ) ) + LOWER( SUBSTRING( InfrastructureName, 2, LEN( InfrastructureName ) ) )
	END AS InfrastructureName,
	GETDATE() AS DWCreatedDate
FROM #LowerCase
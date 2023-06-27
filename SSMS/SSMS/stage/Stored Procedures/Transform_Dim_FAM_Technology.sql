
CREATE PROCEDURE [stage].[Transform_Dim_FAM_Technology]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_FAM_Technology]

INSERT INTO stage.[Dim_FAM_Technology] WITH (TABLOCK) ( FAM_TechnologyKey, TechnologyName )
SELECT DISTINCT
	Technology AS FAM_TechnologyKey,
	UPPER( LEFT( Technology, 1 ) ) + LOWER( SUBSTRING( Technology, 2, LEN( Technology ) ) ) AS TechnologyName
FROM [SourceCubus31PCTI].[BUI_915_Customers_CU]

CREATE PROCEDURE [stage].[Transform_Dim_Technology]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_Technology]

INSERT INTO stage.[Dim_Technology] WITH (TABLOCK) (TechnologyKey)
SELECT DISTINCT technology AS TechnologyKey
FROM sourceNuudlDawnView.ibsitemshistorycharacteristics_History
WHERE technology IS NOT NULL
	AND NUUDL_IsCurrent = 1
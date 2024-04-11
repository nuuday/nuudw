
CREATE PROCEDURE [stage].[Transform_Dim_Technology]
	@JobIsIncremental BIT			
AS 

--CREATE TABLE stage.[Dim_Technology] ( TechnologyKey nvarchar(50), DWCreatedDate datetime2(0) DEFAULT SYSDATETIME() )

TRUNCATE TABLE [stage].[Dim_Technology]

INSERT INTO stage.[Dim_Technology] WITH (TABLOCK) (TechnologyKey)
SELECT DISTINCT SUBSTRING(value_json__corrupt_record,3,LEN(value_json__corrupt_record)-4) TechnologyKey
FROM sourceNuudlNetCrackerView.ibsnrmlcharacteristic_History
WHERE name = 'Technology'
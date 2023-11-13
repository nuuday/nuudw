
CREATE PROCEDURE [stage].[Transform_Fact_Fdemo]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Fact_Fdemo]

INSERT INTO [stage].[Fact_Fdemo] WITH (TABLOCK) ( Demokey,Measure ,[DWCreatedDate] )

select '53f8e009-fc3b-480a-98c7-3f3da3c84924' AS Demokey , 1 AS Measure , getdate() as DWCreatedDate
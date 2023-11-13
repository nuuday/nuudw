
CREATE PROCEDURE [stage].[Transform_Dim_Demo]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_Demo]

INSERT INTO [stage].[Dim_Demo] WITH (TABLOCK) ( Demokey , name,[DWCreatedDate] )



select distinct id AS Demokey , name, getdate() as DWCreatedDate

from [sourceNuudlNetCrackerView].[cimpartyrole_History]

CREATE PROCEDURE [stage].[Transform_Dim_HouseHold]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_HouseHold]

INSERT INTO stage.[Dim_HouseHold] WITH (TABLOCK) (HouseHoldKey)
SELECT  
	CONVERT( NVARCHAR(36), id ) AS HouseHoldKey
FROM [sourceNuudlDawnView].[cimcontactmedium_History] 
WHERE NUUDL_IsLatest =1
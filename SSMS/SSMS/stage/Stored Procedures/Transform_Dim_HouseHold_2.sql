
CREATE PROCEDURE [stage].[Transform_Dim_HouseHold]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_HouseHold]

INSERT INTO stage.[Dim_HouseHold] WITH (TABLOCK) (HouseHoldkey)


SELECT DISTINCT
CONVERT( NVARCHAR(36),id ) AS HouseHoldkey
from [sourceNuudlNetCrackerView].[cimcontactmedium_History]
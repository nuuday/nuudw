
CREATE PROCEDURE [stage].[Transform_Dim_HouseHold]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_HouseHold]

INSERT INTO stage.[Dim_HouseHold] WITH (TABLOCK) (HouseHoldKey,DWCreatedDate)


SELECT DISTINCT
CONVERT( NVARCHAR(36),id ) AS HouseHoldKey,
GETDATE() AS DWCreatedDate
from [sourceNuudlNetCrackerView].[cimcontactmedium_History]
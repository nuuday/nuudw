
CREATE PROCEDURE [stage].[Transform_Dim_Quote]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_Quote]



INSERT INTO [stage].[Dim_Quote] WITH (TABLOCK) (QuoteKey,DWCreatedDate)


select distinct CONVERT( NVARCHAR(10),number) AS QuoteKey,
GETDATE() AS DWCreatedDate
from [sourceNuudlNetCrackerView].[qssnrmlquote_History]
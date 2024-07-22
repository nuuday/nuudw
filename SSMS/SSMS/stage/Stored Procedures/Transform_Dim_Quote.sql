
CREATE PROCEDURE [stage].[Transform_Dim_Quote]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_Quote]

INSERT INTO [stage].[Dim_Quote] WITH (TABLOCK) (QuoteKey)
SELECT DISTINCT
	CONVERT( NVARCHAR(10), number ) AS QuoteKey
FROM [sourceNuudlDawnView].[qssnrmlquote_History]
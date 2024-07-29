
CREATE PROCEDURE [stage].[Transform_Dim_Quote]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_Quote]

INSERT INTO [stage].[Dim_Quote] WITH (TABLOCK) (QuoteKey, QuoteNumber)
SELECT DISTINCT
	id AS QuoteKey,
	CONVERT( NVARCHAR(10), number ) AS QuoteNumber
FROM [sourceNuudlDawnView].[qssnrmlquote_History]
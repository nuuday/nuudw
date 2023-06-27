
CREATE PROCEDURE [stage].[Transform_Dim_FAM_ChipperStatus]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_FAM_ChipperStatus]

INSERT INTO stage.[Dim_FAM_ChipperStatus] WITH (TABLOCK) ( FAM_ChipperStatusKey, ChipperStatusName )

SELECT DISTINCT
	[status] AS FAM_ChipperStatusKey,
	[status] AS ChipperStatusName
FROM sourceNuuDataChipperView.[ChipperTicketsTickets_History]
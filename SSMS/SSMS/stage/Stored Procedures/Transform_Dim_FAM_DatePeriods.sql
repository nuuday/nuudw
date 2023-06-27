
CREATE PROCEDURE stage.Transform_Dim_FAM_DatePeriods
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_FAM_DatePeriods]

/*

---------------------------------------------------------------------------------------
-- EXAMPLE USE OF JobIsIncremental ----------------------------------------------------
---------------------------------------------------------------------------------------

DECLARE @Watermark datetime2 = '1900-01-01'

IF @JobIsIncremental
BEGIN
	SELECT
		@Watermark = MAX(WaterMarkColumn)
	FROM fact.MyTable
END

TRUNCATE TABLE [stage].[Dim_FAM_DatePeriods]
INSERT INTO stage.[Dim_FAM_DatePeriods] WITH (TABLOCK) (A, B, C)
SELECT A, B, C
FROM MyTable
WHERE WaterMarkColumn > @Watermark

*/
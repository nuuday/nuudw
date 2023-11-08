

CREATE PROCEDURE [stage].[Transform_Dim_ContentGenre]
	@JobIsIncremental BIT			
AS 


/**********************************************************************************************************************************************************************
1. Truncate Table
***********************************************************************************************************************************************************************/

TRUNCATE TABLE stage.Dim_ContentGenre

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

TRUNCATE TABLE [stage].[Dim_ContentGenre]

INSERT INTO stage.[Dim_ContentGenre] WITH (TABLOCK) (A, B, C)
SELECT A, B, C
FROM MyTable
WHERE WaterMarkColumn > @Watermark

*/


DROP TABLE if exists #MaxID
DROP TABLE if exists ##UNRESTRICTED

/*Skal kun bruge den nyeste række*/
SELECT ASSET_ID, MAX(id) AS ID_Max
INTO #MaxID
FROM  SourceCubusbivod.VIDEO_METADATA_History  
GROUP BY ASSET_ID

/*Vil ikke have ADULT med, og udvælg nyeste række*/
SELECT 
	ASSET_ID, 
	GENRES
INTO ##UNRESTRICTED
FROM         SourceCubusbivod.VIDEO_METADATA_History  
where 1 = 1
AND CATEGORY <> 'ADULT'
AND id in (select ID_Max from #MaxID)


drop table if exists #SPLIT
drop table if exists #NOSPECIAL

/*Split string, så man har genre opdelt*/
SELECT
	ASSET_ID, 
	GENRES.value as GENRES 
into #SPLIT
FROM 
	##UNRESTRICTED
	cross apply STRING_SPLIT (GENRES,';') GENRES


/*Tage dem fra der har / eller | i navn  */
SELECT *
INTO #NOSPECIAL
FROM 
	#SPLIT
WHERE Genres NOT LIKE '%/%' 
	AND Genres NOT LIKE '%|%'



/*Ovenstående data skal bruges til bridge tabellen også!*/

/******* Koden der skal sætte ind i stage til dim tabellen ********/

	INSERT INTO stage.Dim_ContentGenre WITH (TABLOCK)

		SELECT 	GENRES AS ContentGenreKey 
		--, COUNT(*) AS NUM
		FROM #NOSPECIAL 
		GROUP BY GENRES 
		HAVING (COUNT(*) > 40) --Hvad giver mening her? 
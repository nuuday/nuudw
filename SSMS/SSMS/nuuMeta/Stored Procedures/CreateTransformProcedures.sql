


/**********************************************************************************************************************************************************************
The purpose of this scripts is to create the transform procedures for each object
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [nuuMeta].[CreateTransformProcedures] 
AS

	SET NOCOUNT ON

	DECLARE @Create VARCHAR(MAX)
	DECLARE @Counter INT = 1
	DECLARE @MaxID INT 

	DROP TABLE IF EXISTS #procedures

	SELECT sp.TransformProcedureName, sp.StageTableName, ROW_NUMBER() OVER (ORDER BY sp.TransformProcedureName) ID
	INTO #procedures
	FROM (
		SELECT 
			TransformProcedureName
			, StageTableName
		FROM nuuMetaView.DWObjectDefinitions
		WHERE DWObjectName NOT IN ('Calendar','Time') 
		) sp
	LEFT JOIN INFORMATION_SCHEMA.ROUTINES r ON  r.ROUTINE_SCHEMA + '.' + r.ROUTINE_NAME = sp.TransformProcedureName COLLATE Danish_Norwegian_CI_AS
	WHERE r.ROUTINE_NAME IS NULL

	SET @MaxID = (SELECT MAX(ID) FROM #procedures)

	WHILE @Counter <= @MaxID 
	BEGIN
	
		SELECT 
			@Create = '
CREATE PROCEDURE ' + TransformProcedureName + '
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[' + StageTableName  + ']

/*

---------------------------------------------------------------------------------------
-- EXAMPLE USE OF JobIsIncremental ----------------------------------------------------
---------------------------------------------------------------------------------------

DECLARE @Watermark datetime2 = ''1900-01-01''

IF @JobIsIncremental
BEGIN
	SELECT
		@Watermark = MAX(WaterMarkColumn)
	FROM fact.MyTable
END

TRUNCATE TABLE [stage].[' + StageTableName  + ']
INSERT INTO stage.[' + StageTableName + '] WITH (TABLOCK) (A, B, C)
SELECT A, B, C
FROM MyTable
WHERE WaterMarkColumn > @Watermark

*/


'
		FROM 
			#procedures
		WHERE ID = @Counter

		--PRINT @Create
		EXEC(@Create)
		
		SET @Create = ''

		SET @Counter = @Counter + 1
	
	END

	SET NOCOUNT OFF
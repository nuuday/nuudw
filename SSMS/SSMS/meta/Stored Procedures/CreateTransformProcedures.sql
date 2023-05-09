


/**********************************************************************************************************************************************************************
The purpose of this scripts is to create the transform procedures for each object in the business matrix
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [meta].[CreateTransformProcedures] AS

SET NOCOUNT ON

	DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10)
	DECLARE @DatabaseNameStage NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameStage')
	DECLARE @Create VARCHAR(MAX)
	DECLARE @CreateFinal VARCHAR(MAX)
	DECLARE @Counter INT = 1
	DECLARE @MaxID INT = (SELECT MAX(ID) FROM  meta.BusinessMatrix)
	DECLARE @InformationSchema TABLE (TABLE_NAME NVARCHAR(128))


	INSERT @InformationSchema EXEC('SELECT REPLACE(NAME,''Transform_'','''') FROM [' + @DatabaseNameStage + '].SYS.PROCEDURES')


	WHILE @Counter <= @MaxID BEGIN

		SELECT 
			@Create = '
CREATE PROCEDURE [stage].[Transform_' + TableName + '] ' + @CRLF + @CRLF + IIF(FactAndBridgeIncrementalFlag = 1,'@JobIsIncremental BIT ','') + '
			
AS 
		
/**********************************************************************************************************************************************************************
1. Truncate Table
***********************************************************************************************************************************************************************/

TRUNCATE TABLE [' + IIF(DestinationSchema = 'Temp','stage_temp','stage') + '].[' + TableName  + ']' + IIF(FactAndBridgeIncrementalFlag = 1,'

/**********************************************************************************************************************************************************************
2. Business Logik - Remember to use the input variable @JobIsIncremental to distinguish between full and incremental load. 
***********************************************************************************************************************************************************************/

/*Full Load pattern

	INSERT INTO stage.[' + TableName + '] WITH (TABLOCK)
	(Columns)

	--Apply business logic for full load here

Incremental Pattern

IF @JobIsIncremental = 0 --Full Load

	BEGIN
		
		INSERT INTO stage.[' + TableName + '] WITH (TABLOCK)
		(Columns)

		--Apply business logic for full load here

	END

ELSE --Incremental Load

	BEGIN

		INSERT INTO stage.[' + TableName + '] WITH (TABLOCK)
		(Columns)

		--Apply business logic for incremental load here.
	END*/','

/**********************************************************************************************************************************************************************
2. Business Logik - Remember to use the input variable @JobIsIncremental to distinguish between full and incremental load. 
***********************************************************************************************************************************************************************/

/*Full Load pattern

	INSERT INTO stage.[' + TableName + '] WITH (TABLOCK)
	(Columns)

	--Apply business logic for full load here
*/')

		FROM 
			meta.BusinessMatrix
		WHERE 
			ID = @Counter AND 
			TransformExcludeFlag = 0 AND 
			TableName NOT IN ('Calendar','Time') AND
			TableName NOT IN (SELECT TABLE_NAME FROM @InformationSchema)

		SET @CreateFinal = 'USE [' + @DatabaseNameStage + ']' + @CRLF + 'EXEC(''' + @Create + ''')'
		
		EXEC(@CreateFinal)
		
		SET @Create = ''
		SET @CreateFinal = ''

		SET @Counter = @Counter + 1

	END

SET NOCOUNT OFF


/**********************************************************************************************************************************************************************
The purpose of this scripts is to create the dummy destination tables in stage used  by GenerateFrameworkTransformLayer. The script is executed by BIML
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [meta].[CreateStageTablesFromBusinessMatrix] AS

SET NOCOUNT ON

	DECLARE @DatabaseNameStage NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameStage')
	DECLARE @Create VARCHAR(MAX)
	DECLARE @Counter INT = 1
	DECLARE @MaxID INT = (SELECT MAX(ID) FROM  meta.BusinessMatrix)
	DECLARE @InformationSchema TABLE (TABLE_NAME NVARCHAR(128))

	INSERT @InformationSchema EXEC('SELECT TABLE_NAME FROM [' + @DatabaseNameStage + '].INFORMATION_SCHEMA.TABLES')


	WHILE @Counter <= @MaxID BEGIN

		SELECT 
			@Create = 'CREATE TABLE [' + @DatabaseNameStage + '].[' + IIF(DestinationSchema = 'temp','stage_temp','stage') + '].[' + TableName + '] ([DummyColumn] int) '
		FROM 
			meta.BusinessMatrix
		WHERE 
			ID = @Counter AND 
			TransformExcludeFlag = 0 AND 
			TableName NOT IN ('Calendar','Time') AND
			TableName NOT IN (SELECT TABLE_NAME FROM @InformationSchema)

		EXEC(@Create)
		SET @Create = ''

		SET @Counter = @Counter + 1

	END

SET NOCOUNT OFF
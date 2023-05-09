

/**********************************************************************************************************************************************************************
The purpose of this scripts is to delete rows in the history table based on the period extracted
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [meta].[DeleteIncrementalRows] 

  @TableName NVARCHAR(100)
, @ExtractSchemaName NVARCHAR(100)
, @PrintSQL BIT

AS

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/

DECLARE @ObjectID INT
DECLARE @IncrementalValueColumn NVARCHAR(500)
DECLARE @IsDateFlag BIT
DECLARE @DatabaseNameExtract NVARCHAR(50) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameExtract')

SET @ObjectID = (
					SELECT SourceObjects.ID 
					FROM 
						meta.SourceObjects
					INNER JOIN
						meta.SourceConnections
							ON SourceConnections.ID = SourceObjects.SourceConnectionID
					WHERE 
						SourceObjects.ObjectName = @TableName
						AND SourceConnections.ExtractSchemaName = @ExtractSchemaName
				)

SET @IncrementalValueColumn =	(
									SELECT IIF(IncrementalValueColumnDefinitionInExtract <> '',IncrementalValueColumnDefinitionInExtract, IncrementalValueColumnDefinition)
									FROM meta.SourceObjectIncrementalSetup
									WHERE SourceObjectID = @ObjectID
								)

SET @IsDateFlag = (
					SELECT IsDateFlag
					FROM meta.SourceObjectIncrementalSetup
					WHERE SourceObjectID = @ObjectID
				)

/**********************************************************************************************************************************************************************
1. Execute dynamic SQL script variables
***********************************************************************************************************************************************************************/

DECLARE @SQL NVARCHAR(MAX) 


SET @SQL = '
DECLARE @MinDate NVARCHAR(50)
DECLARE @MaxDate NVARCHAR(50)

SET @MinDate = (SELECT MIN([' + @IncrementalValueColumn + ']) FROM [' + @DatabaseNameExtract + '].[' + @ExtractSchemaName + '].[' + @TableName + '])
SET @MaxDate = (SELECT MAX([' + @IncrementalValueColumn + ']) FROM [' + @DatabaseNameExtract + '].[' + @ExtractSchemaName + '].[' + @TableName + '])

DELETE T1 WITH (TABLOCK) FROM [' + @DatabaseNameExtract + '].[' + @ExtractSchemaName + '].[' + @TableName + '_History] AS T1 WHERE [' + @IncrementalValueColumn + '] >= @MinDate AND [' + @IncrementalValueColumn + '] <= @MaxDate'
	

IF @PrintSQL = 1

	BEGIN
		PRINT(@SQL)
	END

ELSE
	
	BEGIN
		EXEC(@SQL)
	END

SET NOCOUNT OFF
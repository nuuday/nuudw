

CREATE PROCEDURE [meta].[UpdateFrameworkMetaData]

AS

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/

DECLARE @DatabaseNameDW NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameDW')
DECLARE @TableName VARCHAR(100)
DECLARE @SurrogateKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'SurrogateKeySuffix')
DECLARE @BusinessKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'BusinessKeySuffix')


/**********************************************************************************************************************************************************************
1. Create Loop counter variables
***********************************************************************************************************************************************************************/

DECLARE @Counter INT
DECLARE @MaxIDFact INT 
DECLARE @MaxIDDim INT 

SELECT 
	@Counter = 1,
	@MaxIDFact = (SELECT MAX(ID) FROM meta.BusinessMatrix WHERE DestinationSchema IN ('fact','bridge')),
	@MaxIDDim  = (SELECT MAX(ID) FROM meta.BusinessMatrix WHERE DestinationSchema IN ('dim'))

/**********************************************************************************************************************************************************************
2. Update BimlMetaData table
***********************************************************************************************************************************************************************/
INSERT INTO meta.FrameworkMetaData
(BusinessMatrixID)

SELECT 
	BusinessMatrix.ID 
FROM 
	meta.BusinessMatrix 
LEFT JOIN 
	meta.FrameworkMetaData 
		ON FrameworkMetaData.BusinessMatrixID = BusinessMatrix.ID 
WHERE 
	FrameworkMetaData.BusinessMatrixID IS NULL
	AND FrameworkMetaData.SourceObjectID IS NULL
	AND FrameworkMetaData.TargetObjectID IS NULL

DELETE
FROM 
	meta.FrameworkMetaData 
WHERE
	BusinessMatrixID NOT IN (SELECT ID FROM meta.BusinessMatrix) AND BusinessMatrixID IS NOT NULL;

/**********************************************************************************************************************************************************************
3. Create and execute etl.LoadFact for all facts and bridges. This poputes the column SQLScript in the businessmatrix with the source script for all facts and bridges.
   The column SQLScripts is created by BIML
***********************************************************************************************************************************************************************/

DECLARE @FactLoadIsIncrementalLoad NVARCHAR(100)
DECLARE @CounterChar NVARCHAR(100)

WHILE @Counter <= @MaxIDFact

BEGIN

	SELECT 
		   @TableName = TableName,
		   @FactLoadIsIncrementalLoad = CAST(FactAndBridgeIncrementalFlag AS VARCHAR(1)),
		   @CounterChar = CAST(@Counter AS VARCHAR(100))
	FROM 
		meta.BusinessMatrix
	WHERE 
			ID = @Counter 
		AND DestinationSchema IN ('fact','bridge')

IF @TableName <> ''

BEGIN

	EXEC('DECLARE	@PrintSQL' + @CounterChar + ' NVARCHAR(MAX)
		  EXEC [meta].[CreateFactSourceScript]
			@Table = N''' + @TableName + ''',
			@PrintSQL = @PrintSQL' + @CounterChar + ' OUTPUT
		  UPDATE FrameworkMetaData
		  SET SQLScript = @PrintSQL' + @CounterChar + '
		  FROM 
				meta.FrameworkMetaData
		  INNER JOIN
				meta.BusinessMatrix
					ON BusinessMatrix.ID = FrameworkMetaData.BusinessMatrixID
		  WHERE TableName = N''' + @TableName + '''')
	END

	SET @TableName = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
4. Update the BusinessMatrix with the sql used in dimension lookup. 
***********************************************************************************************************************************************************************/

DECLARE @InformationSchema TABLE (TableName NVARCHAR(128), ColumnName NVARCHAR(128),DataType NVARCHAR(128))
DECLARE @DimIDColumn NVARCHAR(MAX)
DECLARE @DimKeyColumns NVARCHAR(MAX)
DECLARE @DimComma NVARCHAR(10)

WHILE @Counter <= @MaxIDDim

BEGIN

	SELECT 
		@TableName = TableName
	FROM 
		meta.BusinessMatrix
	WHERE 
		ID = @Counter
		AND DestinationSchema = 'dim' 

IF @TableName <> ''

	BEGIN
			DELETE FROM @InformationSchema

			INSERT @InformationSchema EXEC('SELECT TABLE_NAME
												  ,COLUMN_NAME
												  ,DATA_TYPE
											FROM 
												[' + @DatabaseNameDW + '].INFORMATION_SCHEMA.COLUMNS
											WHERE 
												TABLE_NAME = ''' + @TableName + ''' 
											AND COLUMN_NAME LIKE ''%' + @BusinessKeySuffix + ''' 
											AND TABLE_SCHEMA = ''dim''
											AND COLUMN_NAME NOT IN (''WeekKey'',''MonthKey'',''QuarterKey'')')

			SET @DimIDColumn = @TableName + @SurrogateKeySuffix

				SELECT
					  @DimKeyColumns = COALESCE(@DimKeyColumns + ', ','') + CASE 
																				WHEN DataType LIKE '%char%' 
																					THEN 'UPPER(' + ColumnName + ') AS [' + ColumnName + ']'
																				ELSE ColumnName 
																			END
				FROM 
					@InformationSchema
				WHERE 
					TableName = @TableName

				SET @DimComma = CASE 
									WHEN @Counter = 1 
										THEN ', ' 
									ELSE '' 
								END

				EXEC('UPDATE FrameworkMetaData
					  SET SQLScript = ''SELECT ' + @DimIDColumn + @DimComma + @DimKeyColumns + ' FROM dim.' + @TableName + '''
					  FROM 
							meta.FrameworkMetaData
					  INNER JOIN
							meta.BusinessMatrix
								ON BusinessMatrix.ID = FrameworkMetaData.BusinessMatrixID
					  WHERE TableName = ''' + @TableName + ''' AND DestinationSchema = ''dim''')

	END

	SET @Counter = @Counter + 1

	SET @DimIDColumn = ''
	SET @DimKeyColumns = ''
	SET @TableName = ''

END

SET @Counter = 1


/**********************************************************************************************************************************************************************
5. Create the dataset with all relations in the DW. The table DWRelations is created by BIML.
***********************************************************************************************************************************************************************/

IF OBJECT_ID('meta.DWRelations', 'U') IS NOT NULL 

TRUNCATE TABLE meta.DWRelations

WHILE @Counter <= @MaxIDFact

BEGIN

	SELECT 
			@TableName = TableName

	FROM 
		meta.BusinessMatrix
	WHERE 
			ID = @Counter 
		AND DestinationSchema IN ('fact','bridge')

IF @TableName <> ''

BEGIN

INSERT meta.[DWRelations]
EXEC meta.CreateDWRelations @Table = @TableName

END

SET @Counter = @Counter + 1

SET @TableName = ''


END

SET NOCOUNT OFF


/**********************************************************************************************************************************************************************
The purpose of this scripts is to create the source Partition SQL for extract packages
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [meta].[MaintainExtractCreatePartitionScript] 

@SourceObjectID INT,
@PrintSQL BIT

AS

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/
DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10)
DECLARE @DatabaseNameExtract NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameExtract')
DECLARE @DefaultMaxDop NVARCHAR(3) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DefaultMaxDop')
	
/**********************************************************************************************************************************************************************
1. Update FrameworkMetaData table with IDs
***********************************************************************************************************************************************************************/
INSERT INTO meta.FrameworkMetaData
(SourceObjectID)

SELECT 
	SourceObjects.ID 
FROM 
	meta.SourceObjects 
LEFT JOIN 
	meta.FrameworkMetaData 
		ON FrameworkMetaData.SourceObjectID = SourceObjects.ID 
WHERE 
	FrameworkMetaData.BusinessMatrixID IS NULL
	AND FrameworkMetaData.SourceObjectID IS NULL
	AND FrameworkMetaData.TargetObjectID IS NULL
	AND SourceObjects.ID = @SourceObjectID

DELETE FROM meta.FrameworkMetaData WHERE SourceObjectID NOT IN (SELECT ID FROM meta.SourceObjects) AND SourceObjectID IS NOT NULL;

/**********************************************************************************************************************************************************************
2. Create and insert data into table variables
**********************************************************************************************************************************************************************/
DECLARE @InformationSchemaTables TABLE (SourceObjectID INT, TableName NVARCHAR(128), ObjectName NVARCHAR(128),OrdinalPosition INT, ParallelizationFlag BIT, PartitionFlag BIT, UseModulusFlag BIT)
INSERT @InformationSchemaTables SELECT SourceObjectID, [Name], [ObjectName], ROW_NUMBER() OVER ( ORDER BY ObjectName), ParallelizationFlag, PartitionFlag, UseModulusFlag FROM meta.SourceObjectDefinitions WHERE SourceObjectID = @SourceObjectID GROUP BY SourceObjectID,Name,ObjectName, ParallelizationFlag, PartitionFlag, UseModulusFlag

/**********************************************************************************************************************************************************************
3. Create Loop counter variables
**********************************************************************************************************************************************************************/
DECLARE @OuterCounter INT = 1
DECLARE @MaxTable INT = (SELECT MAX(OrdinalPosition) FROM @InformationSchemaTables)


/**********************************************************************************************************************************************************************
4. Create outer loop
**********************************************************************************************************************************************************************/
DECLARE @Parallelization BIT
DECLARE @PartitionFlag BIT 
DECLARE @UseModulusFlag BIT




WHILE @OuterCounter <= @MaxTable

BEGIN

	SELECT
	 @PartitionFlag = PartitionFlag
	,@SourceObjectID = SourceObjectID
	,@UseModulusFlag = UseModulusFlag
	FROM 
	@InformationSchemaTables
	WHERE 
	@OuterCounter = OrdinalPosition



/**********************************************************************************************************************************************************************
5. Create and insert data into table variables
**********************************************************************************************************************************************************************/
DECLARE @InformationSchema TABLE (TableName NVARCHAR(128), PartitionDefinition NVARCHAR(max),PartitionLowerBound NVARCHAR(100), PartitionUpperBound NVARCHAR(100), OrdinalPosition INT)

INSERT @InformationSchema 
EXEC('
	SELECT [Name]
		 , REPLACE(SourceObjectPartition.PartitionValueColumnDefinition,'''''''','''''''''''')
		 , PartitionLowerBound
		 , PartitionUpperBound 
		 , ROW_NUMBER() OVER ( ORDER BY ObjectName) 
    FROM 
		meta.SourceObjectDefinitions 
	INNER JOIN 
		meta.SourceObjectPartition 
			ON SourceObjectPartition.SourceObjectID = SourceObjectDefinitions.SourceObjectID 
	WHERE 
		PartitionFlag = 1
		AND SourceObjectDefinitions.SourceObjectID = ' + @SourceObjectID)

/**********************************************************************************************************************************************************************
6. Create Loop counter variables
**********************************************************************************************************************************************************************/
DECLARE @Counter INT
DECLARE @MaxPartitions INT 

SELECT 
	@Counter = 1
   ,@MaxPartitions = (SELECT MAX(OrdinalPosition) FROM @InformationSchema)


/**********************************************************************************************************************************************************************
7. Create loop
**********************************************************************************************************************************************************************/
DECLARE @SQL NVARCHAR(MAX)
DECLARE @PlaceholderSQL NVARCHAR(MAX)
DECLARE @DefaultPartitionSQL NVARCHAR(MAX) = 'WITH Dataset AS (SELECT ROW_NUMBER() OVER ( ORDER BY object_id) AS RowN  FROM sys.all_objects) SELECT 0 AS RowN, ''Dummy'' AS PartitionDefinition, 0 AS PartitionLowerBound, 0 AS PartitionUpperBound  UNION ALL SELECT RowN , ''Dummy'' AS PartitionDefinition, RowN AS PartitionLowerBound, RowN AS PartitionUpperBound FROM Dataset WHERE RowN < (SELECT VariableValue FROM meta.Variables WHERE VariableName = ''DefaultMaxDop'')'

WHILE @Counter <= @MaxPartitions

	BEGIN

		SELECT 
			@PlaceholderSQL = 'SELECT ' + CAST(OrdinalPosition AS NVARCHAR(20)) + ' AS RowN, ''' + PartitionDefinition + ''' AS PartitionDefinition, ' + PartitionLowerBound + ' AS PartitionLowerBound , ' + PartitionUpperBound + ' AS PartitionUpperBound ' + IIF(@Counter = @MaxPartitions,'',' UNION ALL') + @CRLF 
		FROM
			@InformationSchema
		WHERE
			OrdinalPosition = @Counter

		SET @SQL = CONCAT(@SQL,@PlaceholderSQL)

		SET @PlaceholderSQL = ''

		SET @Counter = @Counter + 1

	END


/**********************************************************************************************************************************************************************
8. Update FrameworkMetaDate
**********************************************************************************************************************************************************************/
IF @PrintSQL = 0
	BEGIN
		IF @PartitionFlag = 1 AND @UseModulusFlag = 0
				BEGIN
				   UPDATE meta.FrameworkMetaData
				   SET PartitionSQLScript = @SQL
				   WHERE SourceObjectID = @SourceObjectID
				END
			ELSE
				BEGIN
				   UPDATE meta.FrameworkMetaData
				   SET PartitionSQLScript = @DefaultPartitionSQL
				   WHERE SourceObjectID = @SourceObjectID 
				END
	END
ELSE
	BEGIN
		IF @PartitionFlag = 1 AND @UseModulusFlag = 0
				BEGIN
				  PRINT(@SQL)
				END
			ELSE
				BEGIN
				  PRINT(@DefaultPartitionSQL)
				END
	END

		SET @PlaceholderSQL = ''

		SET @SQL = ''

		SET @Counter = 1


	DELETE FROM @InformationSchema


	SET @PartitionFlag = NULL
	SET @SourceObjectID = NULL
	SET @UseModulusFlag = NULL

	SET @OuterCounter = @OuterCounter + 1

END

SET NOCOUNT OFF
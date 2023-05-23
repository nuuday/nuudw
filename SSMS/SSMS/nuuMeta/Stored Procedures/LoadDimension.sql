

/**********************************************************************************************************************************************************************
The purpose of this scripts is to create and execute the merge join statement between stage tables and dimensions. 
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [nuuMeta].[LoadDimension]
	@StageTable  NVARCHAR(100), --Input is the stage table name without schema
	@DWTable  NVARCHAR(100), --Input is the dimension table name without schema
	@PrintSQL BIT = 0
AS

SET NOCOUNT ON

/*
DECLARE 
	@StageTable  NVARCHAR(100) = 'Dim_CustomerTest', --Input is the dimensions name without schema
	@DWTable  NVARCHAR(100) = 'CustomerTest', --Input is the dimensions name without schema
	@PrintSQL BIT = 1
--*/


/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/
DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10) --Linebreak
DECLARE @SurrogateKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM nuuMetaView.Variables WHERE VariableName = 'SurrogateKeySuffix')
DECLARE @BusinessKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM nuuMetaView.Variables WHERE VariableName = 'BusinessKeySuffix')
DECLARE @StageSchema NVARCHAR(10) = 'stage'


/**********************************************************************************************************************************************************************
1. Create and insert data into table variables
**********************************************************************************************************************************************************************/

DROP TABLE IF EXISTS #InformationSchema
CREATE TABLE #InformationSchema (DatabaseName NVARCHAR(128), TableName NVARCHAR(128), ColumnName NVARCHAR(128), OrdinalPosition INT, DataType NVARCHAR(128))

DROP TABLE IF EXISTS #Type2Columns
CREATE TABLE #Type2Columns (Type2Columns NVARCHAR(500))

DROP TABLE IF EXISTS #ColumnDefaults
CREATE TABLE #ColumnDefaults (DataType NVARCHAR(50),DefaultValue NVARCHAR(250))

/*Generates a dataset with the combined information schema*/
INSERT #InformationSchema (DatabaseName,TableName,ColumnName,OrdinalPosition,DataType)
SELECT
	'Stage' AS DatabaseName,
	TABLE_NAME,
	COLUMN_NAME,
	ORDINAL_POSITION,
	DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE
	TABLE_NAME = @StageTable
	AND TABLE_SCHEMA = @StageSchema
	AND COLUMN_NAME NOT LIKE 'DW%'
UNION ALL
SELECT
	'DW' AS DatabaseName,
	TABLE_NAME,
	COLUMN_NAME,
	ORDINAL_POSITION,
	DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE
	TABLE_NAME = @DWTable
	AND TABLE_SCHEMA = 'dim'


/*Generates a dataset with the Type2 columns*/
INSERT #Type2Columns
SELECT DISTINCT 
	all_columns.Name
FROM sys.TABLES
INNER JOIN sys.schemas
	ON schemas.schema_id = TABLES.schema_id
INNER JOIN sys.all_columns
	ON all_columns.object_id = TABLES.object_id
INNER JOIN sys.extended_properties
	ON extended_properties.major_id = TABLES.object_id
		AND extended_properties.minor_id = all_columns.column_id
		AND extended_properties.class = 1
WHERE 1=1
	AND extended_properties.Name = 'HistoryType'
	AND extended_properties.Value = 'Type2'
	AND schemas.Name = 'dim'
	AND TABLES.Name = @DWTable


/*Generates a dataset with the column default values*/
INSERT #ColumnDefaults 
SELECT
	REPLACE( [name], 'Default', '' ) AS DataType,
	CONVERT( NVARCHAR(128), value ) AS DefaultValue
FROM sys.extended_properties
WHERE
	[name] IN ('DefaultDate', 'DefaultDimensionMemberID', 'DefaultNumber', 'DefaultString', 'DefaultBit')

DECLARE @DefaultString nvarchar(max) = (SELECT DefaultValue FROM #ColumnDefaults WHERE DataType = 'String')
DECLARE @DefaultNumber nvarchar(max) = (SELECT DefaultValue FROM #ColumnDefaults WHERE DataType = 'Number')
DECLARE @DefaultDate nvarchar(max) = (SELECT DefaultValue FROM #ColumnDefaults WHERE DataType = 'Date') 
DECLARE @DefaultBit nvarchar(max) = (SELECT DefaultValue FROM #ColumnDefaults WHERE DataType = 'Bit')
DECLARE @DefaultDimensionMemberID nvarchar(max) = (SELECT DefaultValue FROM #ColumnDefaults WHERE DataType = 'DimensionMemberID')


/**********************************************************************************************************************************************************************
3. Create Merge Keys part and Merge Ouput part
**********************************************************************************************************************************************************************/
DECLARE @Type2HistoryFromSourceKey NVARCHAR(MAX) --If the dimension has the following columns DimensionNameIsCurrent, DimensionNameValidFromDate and DimensionNameValidToDate Type2 history is created in the source
DECLARE @Keys NVARCHAR(MAX) --Holds the value of @PlaceholderKeys for each loop
DECLARE @MergeOutput NVARCHAR(MAX) --Holds the value of @PlaceholderMergeOutput for each loop

SET @Type2HistoryFromSourceKey = (SELECT IIF(COUNT(ColumnName) = 3, ' AND [source].[' + @DWTable + 'ValidFromDate] = [target].[' + @DWTable + 'ValidFromDate]', NULL) FROM #InformationSchema WHERE REPLACE(ColumnName,@DWTable,'') IN ('IsCurrent', 'ValidFromDate', 'ValidToDate') AND DatabaseName = 'Stage' )

SELECT 
	@Keys = STRING_AGG('[source].[' + ColumnName + '] = [target].[' + ColumnName + ']', ' AND ') WITHIN GROUP (ORDER BY OrdinalPosition),
	@MergeOutput = STRING_AGG('MERGE_OUTPUT.[' + ColumnName + '] IS NOT NULL', ' AND ') WITHIN GROUP (ORDER BY OrdinalPosition)
FROM 
	#InformationSchema 
WHERE 
	DatabaseName = 'Stage' and
	ColumnName LIKE '%' + @BusinessKeySuffix
	
SET @Keys = @Keys + ISNULL(@Type2HistoryFromSourceKey,'') --If Type2 history is created in source ValidFromDate is used as key

/**********************************************************************************************************************************************************************
4. Create Column from Source part which handles null values, columns from stage and output column part
**********************************************************************************************************************************************************************/

DECLARE @ColumnNameStage NVARCHAR(MAX) 
DECLARE @ColumnNameSource NVARCHAR(MAX) 
DECLARE @Output NVARCHAR(MAX) 
 
SELECT 
	@ColumnNameSource =
		STRING_AGG(
			CASE 
				WHEN DataType LIKE '%char%' AND ColumnName NOT LIKE '%' + @BusinessKeySuffix AND ColumnName NOT LIKE '%Code'
				THEN 'ISNULL([' + ColumnName + '],''' + @DefaultString + ''') AS [' + ColumnName + ']'
				WHEN DataType IN ('int','tinyint','bigint','smallint','decimal','numeric','float','double','money') AND ColumnName NOT LIKE '%' + @BusinessKeySuffix AND ColumnName NOT LIKE '%Code'
				THEN 'ISNULL([' + ColumnName + '],''' + @DefaultNumber + ''') AS [' + ColumnName + ']'
				WHEN DataType LIKE '%date%' AND ColumnName NOT LIKE '%' + @BusinessKeySuffix AND ColumnName NOT LIKE '%Code'
				THEN 'ISNULL([' + ColumnName + '],''' + @DefaultDate + ''') AS [' + ColumnName + ']'
				WHEN DataType = 'bit' AND ColumnName NOT LIKE '%' + @BusinessKeySuffix AND ColumnName NOT LIKE '%Code'
				THEN 'ISNULL([' + ColumnName + '],''' + @DefaultBit + ''') AS [' + ColumnName + ']'
				WHEN ColumnName LIKE '%Code'
				THEN 'ISNULL([' + ColumnName + '],''' + @DefaultDimensionMemberID + ''') AS [' + ColumnName + ']'
				ELSE '[' + ColumnName + ']' 
			END
			, ',') WITHIN GROUP (ORDER BY OrdinalPosition),
	@ColumnNameStage = STRING_AGG('[' + ColumnName + ']', ',' ) WITHIN GROUP (ORDER BY OrdinalPosition),
	@Output = STRING_AGG('[source].[' + ColumnName + '] AS [' + ColumnName +']', ','  ) WITHIN GROUP (ORDER BY OrdinalPosition)
FROM 
	#InformationSchema
WHERE 
	DatabaseName = 'Stage'


/**********************************************************************************************************************************************************************
5.Create update part and match part for Type1 columns
**********************************************************************************************************************************************************************/

DECLARE @UpdateType1 NVARCHAR(MAX) 
DECLARE @MatchType1 NVARCHAR(MAX) 

SELECT 
	@MatchType1 = 
		STRING_AGG(
			'([target].[' + ColumnName + '] <> [source].[' + ColumnName + ']) OR ([target].[' + ColumnName + '] IS NULL AND [source].[' + ColumnName + '] IS NOT NULL) OR ([target].[' + ColumnName + '] IS NOT NULL AND [source].[' + ColumnName + '] IS NULL)',
			' OR ' 
		) WITHIN GROUP (ORDER BY OrdinalPosition),
	@UpdateType1 = STRING_AGG('[target].[' + ColumnName + '] = [source].[' + ColumnName + ']', ',')  WITHIN GROUP (ORDER BY OrdinalPosition)
FROM #InformationSchema AS InformationSchema 
LEFT JOIN #Type2Columns AS Type ON 
		Type.Type2Columns = InformationSchema.ColumnName
WHERE 
	DatabaseName = 'Stage'
	AND Type.Type2Columns IS NULL
	AND ColumnName NOT LIKE '%' + @BusinessKeySuffix


/**********************************************************************************************************************************************************************
6.Create match part for Type2 columns
**********************************************************************************************************************************************************************/
DECLARE @MatchType2 NVARCHAR(MAX) 

SELECT 
	@MatchType2 = 
		STRING_AGG(
			'([target].[' + ColumnName + '] <> [source].[' + ColumnName + '] OR ([target].[' + ColumnName + '] IS NULL AND [source].[' + ColumnName + '] IS NOT NULL) OR ([target].[' + ColumnName + '] IS NOT NULL AND [source].[' + ColumnName + '] IS NULL))',
			' OR '
		) WITHIN GROUP (ORDER BY OrdinalPosition)
FROM #InformationSchema AS InformationSchema 
INNER JOIN #Type2Columns AS Type on
		Type.Type2Columns = InformationSchema.ColumnName
WHERE 
	DatabaseName = 'Stage' 


/**********************************************************************************************************************************************************************
7. Create columns for insert unknown value
**********************************************************************************************************************************************************************/
DECLARE @ColumnUnknownValue NVARCHAR(MAX) 

SELECT 
	@ColumnUnknownValue =
		STRING_AGG(
			CASE 
				WHEN DataType LIKE 'Date%' THEN '''' + @DefaultDate + ''''
				WHEN DataType LIKE '%char%' THEN '''' + @DefaultString + ''''
				WHEN DataType = 'bit'THEN @DefaultBit					
				WHEN ColumnName LIKE '%Key' OR ColumnName LIKE '%Code' THEN @DefaultDimensionMemberID
				WHEN DataType = 'uniqueidentifier' THEN 'GUID'                                           
				ELSE @DefaultNumber
			END
			, ',')  WITHIN GROUP (ORDER BY OrdinalPosition)
FROM #InformationSchema 
WHERE 
	DatabaseName = 'Stage'


/**********************************************************************************************************************************************************************
8. Fill out the dynamic SQL script variables
**********************************************************************************************************************************************************************/

DECLARE @InsertUnknownScript NVARCHAR(MAX) 
DECLARE @ParametersScript NVARCHAR(MAX) 
DECLARE @Type1Script NVARCHAR(MAX)
DECLARE @Type2Script NVARCHAR(MAX) 
DECLARE @TypeFullScript NVARCHAR(MAX) 

-- Insert unknown
SET @InsertUnknownScript = '
SET IDENTITY_INSERT [dim].[' + @DWTable + '] ON

DELETE FROM [dim].[' + @DWTable + '] WHERE ' + @DWTable + @SurrogateKeySuffix + ' = ' + @DefaultDimensionMemberID + '
INSERT [dim].[' + @DWTable + '] (' + @CRLF +
	'[' + @DWTable + @SurrogateKeySuffix + '],' + @CRLF  +
	@ColumnNameStage + '
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
)
SELECT ' + 
	(SELECT DefaultValue FROM #ColumnDefaults WHERE DataType = 'DimensionMemberID') + ',
	'+ @ColumnUnknownValue + '
	,1
	,''1900-01-01''
	,''9999-12-31''
	,GETDATE()
	,GETDATE()
	,0

SET IDENTITY_INSERT [dim].[' + @DWTable + '] OFF
'

-- Set parameters
SET @ParametersScript = '
DECLARE @CurrentDateTime datetime
DECLARE @MinDateTime datetime
DECLARE @MaxDateTime datetime
DECLARE @BooleanTrue bit
DECLARE @BooleanFalse bit
DECLARE @DateToDateTime datetime

SELECT
	@CurrentDateTime = cast(getdate() as datetime),
	@MinDateTime = cast(''1900-01-01'' as datetime),
	@MaxDateTime = cast(''9999-12-31'' as datetime),
	@BooleanTrue = cast(1 as bit),
	@BooleanFalse = cast(0 as bit),
	@DateToDateTime = getdate()
'

-- Type 1
SET @Type1Script = 

'
-- ==================================================
-- Type1
-- ==================================================

MERGE [dim].['+ @DWTable + '] as [target] USING
(

SELECT 
' + @ColumnNameSource + 'FROM [' + @StageSchema + '].[' + @StageTable + '] 

) as [source]

-- Selects source rows in order to compare them to [target]

ON
(
' + @Keys + '
)

WHEN NOT MATCHED BY TARGET THEN

INSERT 
(
' + @ColumnNameStage + 
',[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeleted]
)

VALUES 
(
' + @ColumnNameStage + 
',@BooleanTrue
,@MinDateTime
,@MaxDateTime
,@CurrentDateTime
,@CurrentDateTime
,@BooleanFalse
)
'
+ CASE WHEN NULLIF(@MatchType1,'') IS NULL THEN '' ELSE 'WHEN MATCHED AND (' + @MatchType1 +')

THEN UPDATE

SET 
'+  @UpdateType1 + ', [target].[DWModifiedDate] = @CurrentDateTime
' END
+ '
WHEN NOT MATCHED BY SOURCE AND 
[target].[' + @DWTable + @SurrogateKeySuffix + '] > 0
AND 
(
([DWIsCurrent] = @BooleanTrue OR ([DWIsCurrent] IS NULL AND @BooleanTrue IS NULL))
)
THEN UPDATE

SET
[target].[DWIsDeleted] = @BooleanTrue
;'

--Type 2
SET @Type2Script =
'

-- ==================================================
-- Type2
-- ==================================================

INSERT INTO [dim].[' + @DWTable +']
(' + @ColumnNameStage + 
',[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeleted]
)
SELECT 
' + @ColumnNameStage + '
,[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeleted]
FROM
(
MERGE [dim].[' + @DWTable +'] as [target]
 USING
(
SELECT 
' + @ColumnNameSource + 'FROM  [' + @StageSchema + '].[' + @StageTable + ']
	) as [source]
	
ON
(
' + @Keys + '
)

WHEN NOT MATCHED BY TARGET

THEN INSERT
(' + @ColumnNameStage + 
',[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeleted])

VALUES
(' + @ColumnNameStage + ',@BooleanTrue
,@MinDateTime
,@MaxDateTime
,@CurrentDateTime
,@CurrentDateTime
,@BooleanFalse
	)

WHEN MATCHED AND
(
([DWIsCurrent] = @BooleanTrue OR ([DWIsCurrent] IS NULL AND @BooleanTrue IS NULL))
)
 AND
( ' + @MatchType2 + ' )

THEN UPDATE
SET  	[DWIsCurrent] = @BooleanFalse,
		[DWValidToDate] = @DateToDateTime
	
OUTPUT $Action as [MERGE_ACTION],
' + @Output + ',@BooleanTrue AS [DWIsCurrent], 
@CurrentDateTime AS [DWValidFromDate],
@MaxDateTime AS [DWValidToDate],
@CurrentDateTime AS [DWCreatedDate],
@CurrentDateTime AS [DWModifiedDate],
@BooleanFalse AS [DWIsDeleted]

)MERGE_OUTPUT
WHERE MERGE_OUTPUT.[MERGE_ACTION] = ''UPDATE''
	AND ' + @MergeOutput + ';
'

SET @TypeFullScript = CONCAT(@ParametersScript,CASE WHEN NULLIF(@MatchType1,'') IS NULL THEN NULL ELSE @Type1Script END,CASE WHEN NULLIF(@MatchType2,'') IS NULL THEN NULL ELSE @Type2Script END)

/**********************************************************************************************************************************************************************
9. Execute dynamic SQL script variables
**********************************************************************************************************************************************************************/

IF @PrintSQL = 0
BEGIN

		EXEC(@InsertUnknownScript)
		EXEC(@TypeFullScript)

END
ELSE
BEGIN

		SELECT 
		CAST('<?SQL --'
			+@CRLF
			+ISNULL(@InsertUnknownScript,'')
			+ISNULL(@TypeFullScript,'')
			+@CRLF
			+ '-- ?>' AS XML) SQLScript

END

SET NOCOUNT OFF
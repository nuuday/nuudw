



/**********************************************************************************************************************************************************************
The purpose of this scripts is to create the SQL for fact and bridge loads
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [nuuMeta].[LoadFact]
 
@StageTable  NVARCHAR(100), --Input is the stage table name without schema
@DWTable  NVARCHAR(100), --Input is the dimension table name without schema
@DWSchema NVARCHAR(10),--Input is fact og bridge schema
@LoadPattern NVARCHAR(50),--Input is the load pattern stated in the businessmatrix
@IncrementalFlag BIT, --Input is 1 if the load is incremental and 0 if it is a full load
@CleanUpPartitionsFlag BIT, --Input is 1 if you want to bypass the temp table in order du clean up add partitions in the cube else 0
@PrintSQL BIT = 0--Input is 1 if you want to Print the dynamic SQL

AS
/*
DECLARE 
	@StageTable  NVARCHAR(100) = 'Fact_ProductSubscriptions', --Input is the dimensions name without schema
	@DWSchema NVARCHAR(10) = 'fact',
	@DWTable  NVARCHAR(100) = 'ProductSubscriptions', --Input is the dimensions name without schema
	@LoadPattern NVARCHAR(50) = 'FactFull',
	@IncrementalFlag BIT = 1,
	@CleanUpPartitionsFlag BIT = 1,
	@PrintSQL BIT = 1
--*/

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/

DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10)
DECLARE @DatabaseNameStage NVARCHAR(128) = (SELECT VariableValue FROM nuuMetaView.Variables WHERE VariableName = 'DatabaseNameStage')
DECLARE @DatabaseNameMeta NVARCHAR(128) = (SELECT VariableValue FROM nuuMetaView.Variables WHERE VariableName = 'DatabaseNameMeta')
DECLARE @DatabaseNameDW NVARCHAR(128) = (SELECT VariableValue FROM nuuMetaView.Variables WHERE VariableName = 'DatabaseNameDW')
DECLARE @SurrogateKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM nuuMetaView.Variables WHERE VariableName = 'SurrogateKeySuffix')
DECLARE @BusinessKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM nuuMetaView.Variables WHERE VariableName = 'BusinessKeySuffix')
DECLARE @IncrementalFact BIT = @IncrementalFlag
DECLARE @IsCloudFlag BIT = 1
DECLARE @StageSchema NVARCHAR(10) = 'stage' 
DECLARE @MaxCalendarKey NVARCHAR(10)  = (SELECT MAX(CalendarKey) FROM dim.Calendar)


/**********************************************************************************************************************************************************************
1. Create and insert data into table variables
***********************************************************************************************************************************************************************/
DROP TABLE IF EXISTS #InformationSchema
DROP TABLE IF EXISTS #Dimensions
DROP TABLE IF EXISTS #Type2CombinedKeys
DROP TABLE IF EXISTS #Type2FromSource

CREATE TABLE #InformationSchema (DatabaseName NVARCHAR(128),TableName NVARCHAR(128), ColumnName NVARCHAR(128), OrdinalPosition INT, DataType NVARCHAR(128), PrimaryKey INT)
CREATE TABLE #Dimensions (TableName NVARCHAR(128), DimensionTable NVARCHAR(128), ColumnName NVARCHAR(128),ColumnMapping NVARCHAR(128),RolePlayingDimension NVARCHAR(128),IsType2Dimension NVARCHAR(10), IsType2CompositeKeyDimension NVARCHAR(10),OrdinalPosition INT,NewDimension NVARCHAR(128), ErrorValue NVARCHAR(128))
CREATE TABLE #Type2CombinedKeys (DimensionTable NVARCHAR(128), ColumnName NVARCHAR(128), ColumnMapping NVARCHAR(128),OrdinalPosition INT, RolePlayingDimension NVARCHAR(128),NewDimension NVARCHAR(128), ErrorValue NVARCHAR(128))
CREATE TABLE #Type2FromSource (DimensionTable NVARCHAR(128))

/*Generates the combined information schema*/


INSERT INTO #InformationSchema ( DatabaseName, TableName, ColumnName, OrdinalPosition, DataType, PrimaryKey )
SELECT
	'Stage' AS DatabaseName,
	COLUMNS.TABLE_NAME AS TableName,
	COLUMNS.COLUMN_NAME AS ColumnName,
	COLUMNS.ORDINAL_POSITION,
	COLUMNS.DATA_TYPE AS DataType,
	CASE WHEN COLUMN_NAME LIKE '%Identifier' THEN 1 ELSE 0 END AS PrimaryKey
FROM INFORMATION_SCHEMA.COLUMNS
WHERE
	COLUMNS.TABLE_NAME = @StageTable
	AND COLUMNS.COLUMN_NAME NOT LIKE 'DW%'
	AND COLUMNS.TABLE_SCHEMA = @StageSchema
								
/*Generates the mapping dataset between fact/bridge and dimensions*/
INSERT INTO #Dimensions (TableName,DimensionTable,ColumnName,ColumnMapping,RolePlayingDimension,IsType2Dimension,IsType2CompositeKeyDimension,OrdinalPosition,NewDimension,ErrorValue)
EXEC nuuMeta.CreateDWRelations @Table = @StageTable  

DROP TABLE IF EXISTS #DW
SELECT
	'DW' AS DatabaseName,
	inf.TableName,
	ISNULL( dim.RolePlayingDimension + 'ID', inf.ColumnName ) AS ColumnName,
	LEAD( dim.RolePlayingDimension ) OVER (PARTITION BY dim.RolePlayingDimension ORDER BY inf.ColumnName) AS Lead,
	ROW_NUMBER() OVER (ORDER BY inf.OrdinalPosition) AS OrdinalPosition,
	IIF( dim.RolePlayingDimension IS NOT NULL, 'int', inf.DataType ) AS DataType,
	inf.PrimaryKey
INTO #DW
FROM #InformationSchema AS inf
LEFT JOIN #Dimensions AS dim
	ON dim.ColumnName = inf.ColumnName
GROUP BY inf.DatabaseName, inf.TableName, dim.RolePlayingDimension, inf.ColumnName, inf.OrdinalPosition, inf.DataType, inf.PrimaryKey

INSERT INTO #InformationSchema (DatabaseName,TableName,ColumnName,OrdinalPosition,DataType,PrimaryKey) 
SELECT
	DatabaseName,
	TableName,
	ColumnName,
	ROW_NUMBER() OVER (ORDER BY OrdinalPosition),
	DataType,
	PrimaryKey
FROM #DW
WHERE
	lead IS NULL


/*Generates a dataset with composite Type2 keys*/
INSERT INTO #Type2CombinedKeys (DimensionTable,ColumnName,ColumnMapping,OrdinalPosition,RolePlayingDimension,NewDimension,ErrorValue)
SELECT
	dim.DimensionTable,
	inf.ColumnName,
	dim.ColumnMapping,
	ROW_NUMBER() OVER (ORDER BY CASE
		WHEN dim.RolePlayingDimension IS NULL THEN dim.DimensionTable
		ELSE dim.RolePlayingDimension
	END, inf.OrdinalPosition) AS ORDINAL_POSITION,
	CASE
		WHEN dim.RolePlayingDimension IS NULL THEN dim.DimensionTable
		ELSE dim.RolePlayingDimension
	END,
	CASE
		WHEN ROW_NUMBER() OVER (PARTITION BY CASE
			WHEN dim.RolePlayingDimension IS NULL THEN dim.DimensionTable
			ELSE dim.RolePlayingDimension
		END ORDER BY dim.DimensionTable, inf.OrdinalPosition) = 1 THEN N'Yes'
		ELSE N'No'
	END,
	dim.ErrorValue
FROM #InformationSchema AS inf
LEFT JOIN #Dimensions AS dim
	ON dim.ColumnName = inf.ColumnName
WHERE
	dim.IsType2Dimension = 'Yes'
	AND inf.DatabaseName = 'Stage'

INSERT #Type2FromSource (DimensionTable)
SELECT DISTINCT
	table_name AS DimensionTable
FROM INFORMATION_SCHEMA.COLUMNS
WHERE
	REPLACE( column_name, table_name, '' ) IN ('IsCurrent', 'ValidFromDate', 'ValidToDate')
	AND TABLE_SCHEMA = 'dim' 				
		

/**********************************************************************************************************************************************************************
2. Create Loop counter variables and Type2FromSource variable
***********************************************************************************************************************************************************************/

DECLARE @Counter INT 
DECLARE @MaxColumns INT  --Number of columns from stage
DECLARE @MaxType2JoinColumns INT --Max position of composite Type2 key columns
DECLARE @MaxJoinColumns INT --Max position of key columns from fact/bridge
DECLARE @MaxColumnsKeys INT --Max position of primary key columns i fact/bridge
DECLARE @MaxColumnsFact INT --Number of columns in fact/bridge

	 
/**********************************************************************************************************************************************************************
3. Create position and support variables
***********************************************************************************************************************************************************************/
DECLARE @HasCalendarKey INT 
DECLARE @HasTimeKey INT 
DECLARE @CalendarName SYSNAME

SELECT TOP 1 @CalendarName = ColumnName
FROM #InformationSchema 
WHERE ColumnName IN ('Calendar'+ @BusinessKeySuffix, 'CalendarFrom'+ @BusinessKeySuffix)
ORDER BY CASE WHEN ColumnName = 'Calendar'+ @BusinessKeySuffix THEN 0 ELSE 1 END

SELECT
	   @HasCalendarKey = CASE WHEN (SELECT COUNT(*) FROM #InformationSchema WHERE ColumnName = @CalendarName) > 0 THEN 1 ELSE 0 END --Check if CalendarKey is present
	  ,@HasTimeKey = CASE WHEN (SELECT COUNT(*) FROM #InformationSchema WHERE ColumnName = 'Time' + @BusinessKeySuffix) > 0 THEN 1 ELSE 0 END --Check if TimeKey is present


/**********************************************************************************************************************************************************************
5. Create the select part of the source code for non ID columns
***********************************************************************************************************************************************************************/
DECLARE @Select NVARCHAR(MAX) = ''

SELECT @Select = STRING_AGG(CAST('[' + inf.TableName + '].[' + inf.ColumnName + ']' AS NVARCHAR(MAX)),',')
FROM #InformationSchema AS inf
WHERE inf.DatabaseName = 'Stage'
	AND inf.ColumnName NOT LIKE '%'+@BusinessKeySuffix

SET @Select = @Select + ','


/**********************************************************************************************************************************************************************
6. Create the select Type2 ID with error handling
***********************************************************************************************************************************************************************/
DECLARE @IDType2Merge NVARCHAR(MAX)
DECLARE @IDType2Columns NVARCHAR(MAX)
DECLARE @IDType2 NVARCHAR(MAX)

SELECT 
	@IDType2Merge = STRING_AGG(CAST('ISNULL([' + RolePlayingDimension + '].[' + DimensionTable + @SurrogateKeySuffix + '],' + ErrorValue +') AS [' + RolePlayingDimension + @SurrogateKeySuffix + ']' AS NVARCHAR(MAX)),',')	
	, @IDType2Columns = STRING_AGG(CAST('[' + RolePlayingDimension + @SurrogateKeySuffix + ']' AS NVARCHAR(MAX)),',')	
	, @IDType2 = STRING_AGG('[' + RolePlayingDimension + '].[' + DimensionTable + @SurrogateKeySuffix + ']' + CASE WHEN RolePlayingDimension <> DimensionTable THEN ' AS [' + RolePlayingDimension + @SurrogateKeySuffix + ']'	ELSE '' END,',')	
FROM #Type2CombinedKeys
WHERE NewDimension = 'Yes' 

SET @IDType2Merge = @IDType2Merge + ','
SET @IDType2Columns = @IDType2Columns + ','
SET @IDType2 = @IDType2 + ','
   

/**********************************************************************************************************************************************************************
7. Create the select ID part for source code 
***********************************************************************************************************************************************************************/
DECLARE @IDMerge NVARCHAR(MAX) 
DECLARE @ColumnNameIDFact NVARCHAR(MAX) 

SELECT
	@IDMerge = STRING_AGG(
		CAST(
			CASE
				WHEN RolePlayingDimension IS NOT NULL THEN 'ISNULL([' + RolePlayingDimension + '].[' + DimensionTable + @SurrogateKeySuffix + '],' + ErrorValue + ') AS [' + RolePlayingDimension + @SurrogateKeySuffix + ']'
				ELSE 'ISNULL([' + DimensionTable + '].[' + DimensionTable + @SurrogateKeySuffix + '],' + ErrorValue + ') AS ' + '[' + DimensionTable + @SurrogateKeySuffix + ']'
			END 
		AS NVARCHAR(MAX)), ',')
	,@ColumnNameIDFact = STRING_AGG(
		CAST(
			CASE
				WHEN RolePlayingDimension IS NOT NULL THEN '[' + RolePlayingDimension + @SurrogateKeySuffix + ']' 
				ELSE '[' + DimensionTable + @SurrogateKeySuffix + ']'
			END		
		AS NVARCHAR(MAX)),',')
FROM #Dimensions
WHERE
	NewDimension = 'Yes'
	AND IsType2Dimension = 'No'

SET @IDMerge = @IDMerge + ','
SET @ColumnNameIDFact = @ColumnNameIDFact + ','

/**********************************************************************************************************************************************************************
8. Create the the left join part for Type2 dimensions
***********************************************************************************************************************************************************************/
DECLARE @LeftJoinType2 NVARCHAR(MAX) 
DECLARE @DatetimeValue NVARCHAR(MAX)

/* DatetimeValue is set dependent on if there is a timehour key or not. If there is we convert calendarkey and time keys into a datetime. The replicate function makes sure to add a leading 0 if we are at single digit number */
SET @DatetimeValue =
	CASE 
		WHEN @HasTimeKey=1 THEN 'Convert(datetime2(0), CONCAT([' + @StageTable + '].[' + @CalendarName +'], '' '',[TimeKey]))'
		ELSE 'Convert(datetime2(0), CONCAT([' + @StageTable + '].[' + @CalendarName +'], '' '',''23:59:59''))' -- If the dimension have datetime values we want to catch the value end of day.
	END
	
SELECT
	@LeftJoinType2 = STRING_AGG(
		CAST(CASE
			WHEN NewDimension = 'Yes' THEN 'LEFT JOIN [' + @DatabaseNameDW + '].[dim].[' + Type2CombinedKeys.DimensionTable + '] ' +
					CASE
						WHEN RolePlayingDimension IS NOT NULL THEN ' AS [' + RolePlayingDimension + ']'
						ELSE ''
					END + @CRLF + 'ON  ' +
					CASE
						WHEN @HasCalendarKey = 1 AND Type2FromSource.DimensionTable IS NULL THEN @DatetimeValue + ' >= [' + RolePlayingDimension + '].[DWValidFromDate] AND ' + @DatetimeValue + ' < [' + RolePlayingDimension + '].[DWValidToDate]'
						WHEN @HasCalendarKey = 1 AND Type2FromSource.DimensionTable IS NOT NULL THEN @DatetimeValue + ' >= [' + RolePlayingDimension + '].[' + Type2FromSource.DimensionTable + 'ValidFromDate] AND ' + @DatetimeValue + ' < [' + RolePlayingDimension + '].[' + Type2FromSource.DimensionTable + 'ValidToDate]'
						WHEN @HasCalendarKey = 0 AND Type2FromSource.DimensionTable IS NOT NULL THEN '[' + RolePlayingDimension + '].[' + Type2FromSource.DimensionTable + 'IsCurrent] = 1 '
						ELSE '[' + RolePlayingDimension + '].[DWIsCurrent] = 1 '
					END + @CRLF + 'AND [' + RolePlayingDimension + '].[' + ColumnMapping + '] = [' + @StageTable + '].[' + ColumnName + ']'
						+ @CRLF + 'AND [' + RolePlayingDimension + '].[DWIsDeleted] = 0'
			ELSE 'AND [' + RolePlayingDimension + '].[' + ColumnMapping + '] = [' + @StageTable + '].[' + ColumnName + ']'
		END AS NVARCHAR(MAX)), @CRLF)
FROM #Type2CombinedKeys AS Type2CombinedKeys
LEFT JOIN #Type2FromSource AS Type2FromSource
	ON Type2FromSource.DimensionTable = Type2CombinedKeys.DimensionTable



/**********************************************************************************************************************************************************************
9. Create the left join part for non Type2 dimensions
***********************************************************************************************************************************************************************/
DECLARE @LeftJoin NVARCHAR(MAX)

SELECT
	@LeftJoin = STRING_AGG(
		CAST(CASE
			WHEN NewDimension = 'Yes' THEN 'LEFT JOIN [' + @DatabaseNameDW + '].[dim].[' + DimensionTable + '] ' +
					CASE
						WHEN RolePlayingDimension IS NOT NULL THEN ' AS [' + RolePlayingDimension + ']'
						ELSE ''
					END + @CRLF + 'ON [' +
					CASE
						WHEN RolePlayingDimension IS NOT NULL THEN RolePlayingDimension
						ELSE DimensionTable
					END + '].[' + ColumnMapping + '] =' +

					CASE
						WHEN ColumnMapping = 'CalendarKey' THEN ' IIF([' + @StageTable + '].[' + ColumnName + '] > ''' + @MaxCalendarKey + ''',''' + @MaxCalendarKey + ''',[' + @StageTable + '].[' + ColumnName + '] )'
						ELSE '[' + @StageTable + '].[' + ColumnName + ']'
					END

			ELSE 'AND [' +
					CASE
						WHEN RolePlayingDimension IS NOT NULL THEN RolePlayingDimension
						ELSE DimensionTable
					END + '].[' + ColumnMapping + '] = ' +

					CASE
						WHEN ColumnMapping = 'CalendarKey' THEN ' IIF([' + @StageTable + '].[' + ColumnName + '] > ''' + @MaxCalendarKey + ''',''' + @MaxCalendarKey + ''',[' + @StageTable + '].[' + ColumnName + '] )'
						ELSE '[' + @StageTable + '].[' + ColumnName + ']'
					END
		END AS NVARCHAR(MAX)), @CRLF)
FROM #Dimensions
WHERE IsType2Dimension = 'No'


/**********************************************************************************************************************************************************************
10. Create the key part of the merge join statement
***********************************************************************************************************************************************************************/

DECLARE @Keys NVARCHAR(MAX) --Holds the value of @Keys

SELECT
	@Keys = STRING_AGG(CAST('[source].[' + ColumnName + '] = [target].[' + ColumnName + ']' AS NVARCHAR(MAX)),' AND ')
FROM #InformationSchema
WHERE
	PrimaryKey = 1
	AND DatabaseName = 'DW'


/**********************************************************************************************************************************************************************
11. Create the columns from stage for the merge script
***********************************************************************************************************************************************************************/
DECLARE @ColumnNameFact NVARCHAR(MAX) --Holds the value of @ColumnNameDim for each loop

SELECT @ColumnNameFact = STRING_AGG(CAST('[' + InformationSchema.ColumnName + ']' AS NVARCHAR(MAX)),',')
FROM #InformationSchema AS InformationSchema	
WHERE DatabaseName = 'DW'
	AND InformationSchema.ColumnName NOT LIKE '%ID'

SET @ColumnNameFact = @ColumnNameFact + ','


/**********************************************************************************************************************************************************************
12. Create the match part and the update part for the merge script
***********************************************************************************************************************************************************************/
DECLARE @UpdateType1 NVARCHAR(MAX) --Holds the value of @ColumnNameDim for each loop
DECLARE @MatchType1 NVARCHAR(MAX) --Holds the value of @ColumnNameDim for each loop

SELECT
	@MatchType1 = STRING_AGG(CAST('([target].[' + ColumnName + '] <> [source].[' + ColumnName + ']) OR ([target].[' + ColumnName + '] IS NULL AND [source].[' + ColumnName + '] IS NOT NULL) OR ([target].[' + ColumnName + '] IS NOT NULL AND [source].[' + ColumnName + '] IS NULL)' AS NVARCHAR(MAX)), ','),
	@UpdateType1 = STRING_AGG(CAST('[target].[' + ColumnName + '] = [source].[' + ColumnName + ']' AS NVARCHAR(MAX)),',')
FROM #InformationSchema
WHERE
	DatabaseName = 'DW'


/**********************************************************************************************************************************************************************
13. Create the delta part of the source code
***********************************************************************************************************************************************************************/
DECLARE @SelectDelta NVARCHAR(MAX) = ''

SELECT @SelectDelta  = 
	STRING_AGG(
		CASE 
			WHEN ColumnName NOT LIKE '%ID' AND ColumnName NOT LIKE '%Code' AND ColumnName NOT LIKE '%Number' AND Datatype IN ('Decimal','Numeric','int','bigint') THEN '-'
			ELSE ''
		END + '[target].[' + InformationSchema.ColumnName + ']'
	,',')
FROM 
	#InformationSchema AS InformationSchema	
WHERE InformationSchema.DatabaseName = 'DW'
	AND InformationSchema.ColumnName <> 'LastValueLoaded'


/**********************************************************************************************************************************************************************
14. Fill out dynamic SQL variables
***********************************************************************************************************************************************************************/

DECLARE @DeleteFromFact NVARCHAR(MAX) --Holds the Type1 part of the Merge Join Script
DECLARE @SQLFullLoad NVARCHAR(MAX) --Holds the Type1 part of the Merge Join Script
DECLARE @SQLDelta NVARCHAR(MAX)
DECLARE @SQLReplacement NVARCHAR(MAX)
DECLARE @SQLStandard NVARCHAR(MAX)
DECLARE @SQLAdd NVARCHAR(MAX)
DECLARE @SQLMergeJoin NVARCHAR(MAX) --Holds the Type1 part of the Merge Join Script
DECLARE @SQL NVARCHAR(MAX) --Holds the Type1 part of the Merge Join Script

SET @SQLMergeJoin ='
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
	@DateToDateTime = dateadd(ms,-3,  getdate())

-- ==================================================
-- Type1
-- ==================================================

MERGE [' + @DatabaseNameDW + '].[' + @DWSchema + '].['+ @DWTable + '] as [target] USING
	  [' + @DatabaseNameDW + '].[' + @DWSchema + '].[' + @DWTable + '_Temp] as [source]

-- Selects source rows in order to compare them to [target]

ON
(
' + @Keys + '
)

WHEN NOT MATCHED BY TARGET THEN

INSERT 
(
' 
+ ISNULL(@IDType2Columns,'') +
+ ISNULL(@ColumnNameIDFact,'') +
+ ISNULL(@ColumnNameFact,'') + '
[DWCreatedDate]
,[DWModifiedDate]
)
VALUES 
('  
+ ISNULL(@IDType2Columns,'') +
+ ISNULL(@ColumnNameIDFact,'') +
+ ISNULL(@ColumnNameFact,'') + '
@CurrentDateTime
,@CurrentDateTime
)


WHEN MATCHED 

THEN UPDATE

SET 
'+  @UpdateType1 + ', [target].[DWModifiedDate] = @CurrentDateTime

;'


SET @SQLFullLoad = 'TRUNCATE TABLE [' + @DatabaseNameDW + '].[' + @DWSchema + '].['+ @DWTable + '] 

EXEC [' + @DatabaseNameMeta + '].nuuMeta.[MaintainDWFactIndexes] @DWTable = ''' + @DWTable + ''', @DWSchema = ''' + @DWSchema + ''',@DisableIndexes = 1, @PrintSQL = 0
 
DECLARE @UpdateDateTime datetime = GETDATE()

INSERT INTO [' + @DatabaseNameDW + '].[' + @DWSchema + '].['+ @DWTable + '] WITH (TABLOCK)
(
'   + ISNULL(@IDType2Columns,'') 
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	DWCreatedDate
	,DWModifiedDate
)  

SELECT 
	' + ISNULL(@IDType2Merge,'')
	  + ISNULL(@IDMerge,'')
	  + ISNULL(@Select,'') 
	  + '
	@UpdateDateTime
	,@UpdateDateTime
FROM [' + @DatabaseNameStage + '].[' + @StageSchema + '].['+ @StageTable + '] AS ' + @StageTable + ' ' + @CRLF +
ISNULL(@LeftJoinType2,'') + 
ISNULL(@LeftJoin,'') + @CRLF + @CRLF +

'EXEC [' + @DatabaseNameMeta + '].nuuMeta.[MaintainDWFactIndexes] @DWTable = ''' + @DWTable + ''', @DWSchema = ''' + @DWSchema + ''', @DisableIndexes = 0, @PrintSQL = 0'


SET @SQLStandard = 'TRUNCATE TABLE [' + @DatabaseNameDW + '].[' + @DWSchema + '].['+ @DWTable + '_Temp] 

DECLARE @UpdateDateTime datetime = GETDATE()

INSERT INTO [' + @DatabaseNameDW + '].[' + @DWSchema + '].['+ @DWTable + '_Temp] WITH (TABLOCK)
(
'   + ISNULL(@IDType2Columns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	DWCreatedDate
	,DWModifiedDate
)  

SELECT 
	' + ISNULL(@IDType2Merge,'')
	  + ISNULL(@IDMerge,'')
	  + ISNULL(@Select ,'')
	  + '
	  @UpdateDateTime AS DWCreatedDate
	  , @UpdateDateTime AS DWModifiedDate
FROM [' + @DatabaseNameStage + '].[' + @StageSchema + '].['+ @StageTable + '] AS ' + @StageTable + ' ' + @CRLF +
ISNULL(@LeftJoinType2,'') + 
ISNULL(@LeftJoin,'') + @CRLF + @CRLF 


SET @SQLAdd = 'TRUNCATE TABLE [' + @DatabaseNameDW + '].[' + @DWSchema + '].['+ @DWTable + '_Temp] 

BEGIN TRY
    BEGIN TRAN

DECLARE @UpdateDateTime datetime = GETDATE()

INSERT INTO [' + @DatabaseNameDW + '].[' + @DWSchema + '].['+ @DWTable + '] WITH (TABLOCK)
(
'   + ISNULL(@IDType2Columns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	DWCreatedDate
	,DWModifiedDate
)  

SELECT 
	' + ISNULL(@IDType2Merge,'')
	  + ISNULL(@IDMerge,'')
	  + ISNULL(@Select ,'')
	  + '@UpdateDateTime' + @CRLF + ', @UpdateDateTime
FROM [' + @DatabaseNameStage + '].[' + @StageSchema + '].['+ @StageTable + '] AS ' + @StageTable + ' 
' 
+ ISNULL(@LeftJoinType2,'') 
+ ISNULL(@LeftJoin,'') 
+

IIF(@CleanUpPartitionsFlag = 0,'

INSERT INTO [' + @DatabaseNameDW + '].[' + @DWSchema + '].['+ @DWTable + '_Temp] WITH (TABLOCK)
(
'   + ISNULL(@IDType2Columns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	DWCreatedDate
	,DWModifiedDate
)  

SELECT 
	' + ISNULL(@IDType2Merge,'')
	  + ISNULL(@IDMerge,'')
	  + ISNULL(@Select ,'')
	  + '@UpdateDateTime AS DWCreatedDate ' + @CRLF + ', @UpdateDateTime AS DWModifiedDate
FROM [' + @DatabaseNameStage + '].[' + @StageSchema + '].['+ @StageTable + '] AS ' + @StageTable + ' 
' 
+ ISNULL(@LeftJoinType2,'') 
+ ISNULL(@LeftJoin,''),'')
+ ' 
COMMIT TRAN

END TRY
BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN; --RollBack in case of Error
		THROW;  
END CATCH'

-------------------------------------------------------
-- @DeleteFromFact
-------------------------------------------------------
SET @DeleteFromFact = '
DELETE [target] WITH (TABLOCK)
FROM
	[' + @DatabaseNameDW + '].[' + @DWSchema + '].['+ @DWTable + '] AS [target]'  + @CRLF +
'INNER JOIN
	[' + @DatabaseNameStage + '].[' + @StageSchema + '].['+ @DWTable + '] AS [source]' + @CRLF + 'ON ' +
	+ @Keys


-------------------------------------------------------
-- @SQLDelta
-------------------------------------------------------
SET @SQLDelta = 'TRUNCATE TABLE [' + @DatabaseNameDW + '].[' + @DWSchema + '].['+ @DWTable + '_Temp] ' + @CRLF + @CRLF +

'BEGIN TRY
    BEGIN TRAN' + @CRLF + @CRLF +
		
IIF(@CleanUpPartitionsFlag = 0,' EXEC [' + @DatabaseNameMeta + '].nuuMeta.FactPatternsDelta @DWTable = ''' + @DWTable + ''', @DWSchema = ''' + @DWSchema + ''', @CleanUpPartitionsFlag = 0, @PrintSQL = 0','')  + @CRLF +
IIF(@CleanUpPartitionsFlag = 1,@DeleteFromFact,'') + @CRLF + @CRLF +  

'
DECLARE @UpdateDateTime datetime = GETDATE()

INSERT INTO [' + @DatabaseNameDW + '].[' + @DWSchema + '].['+ @DWTable + '] WITH (TABLOCK)
(
'   + ISNULL(@IDType2Columns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	DWCreatedDate
	,DWModifiedDate
)  

SELECT 
	' + ISNULL(@IDType2Merge,'')
	  + ISNULL(@IDMerge,'')
	  + ISNULL(@Select ,'')
	  + '@UpdateDateTime' + @CRLF + ', @UpdateDateTime
FROM [' + @DatabaseNameStage + '].[' + @StageSchema + '].['+ @StageTable + '] AS ' + @StageTable + ' ' + @CRLF +
ISNULL(@LeftJoinType2,'') + 
ISNULL(@LeftJoin,'') + @CRLF + @CRLF +

IIF(@CleanUpPartitionsFlag = 0,
'INSERT INTO [' + @DatabaseNameDW + '].[' + @DWSchema + '].['+ @DWTable + '_Temp] WITH (TABLOCK)
(
'   + ISNULL(@IDType2Columns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	DWCreatedDate
	,DWModifiedDate
)  

SELECT 
	' + ISNULL(@IDType2Merge,'')
	  + ISNULL(@IDMerge,'')
	  + ISNULL(@Select ,'')
	  + '@UpdateDateTime AS DWCreatedDate ' + @CRLF + ', @UpdateDateTime AS DWModifiedDate
FROM [' + @DatabaseNameStage + '].[' + @StageSchema + '].['+ @StageTable + '] AS ' + @StageTable + ' ' + @CRLF +
ISNULL(@LeftJoinType2,'') + 
ISNULL(@LeftJoin,'')
,'') + @CRLF + @CRLF +

'COMMIT TRAN
END TRY
BEGIN CATCH
		IF @@TRANCOUNT > 0		
			ROLLBACK TRAN; --RollBack in case of Error
		THROW;  
END CATCH'


-------------------------------------------------------
-- @SQLReplacement
-------------------------------------------------------

SET @SQLReplacement = 'TRUNCATE TABLE [' + @DatabaseNameDW + '].[' + @DWSchema + '].['+ @DWTable + '_Temp] ' + @CRLF + @CRLF +

'BEGIN TRY
    BEGIN TRAN' + @CRLF + @CRLF +
		
IIF(@CleanUpPartitionsFlag = 0,' EXEC [' + @DatabaseNameMeta + '].nuuMeta.FactPatternsReplacement @DWTable = ''' + @DWTable + ''', @DWSchema = ''' + @DWSchema + ''', @CleanUpPartitionsFlag = 0, @PrintSQL = 0','')  + @CRLF +
IIF(@CleanUpPartitionsFlag = 1,' EXEC [' + @DatabaseNameMeta + '].nuuMeta.FactPatternsReplacement @DWTable = ''' + @DWTable + ''', @DWSchema = ''' + @DWSchema + ''', @CleanUpPartitionsFlag = 1, @PrintSQL = 0','') + @CRLF + @CRLF +  

'DECLARE @UpdateDateTime datetime = GETDATE()

INSERT INTO [' + @DatabaseNameDW + '].[' + @DWSchema + '].['+ @DWTable + '] WITH (TABLOCK)
(
'   + ISNULL(@IDType2Columns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	DWCreatedDate
	,DWModifiedDate
)  

SELECT 
	' + ISNULL(@IDType2Merge,'')
	  + ISNULL(@IDMerge,'')
	  + ISNULL(@Select ,'')
	  + '@UpdateDateTime' + @CRLF + ', @UpdateDateTime
FROM [' + @DatabaseNameStage + '].[' + @StageSchema + '].['+ @StageTable + '] AS ' + @StageTable + ' ' + @CRLF +
ISNULL(@LeftJoinType2,'') + 
ISNULL(@LeftJoin,'') + @CRLF + @CRLF +

IIF(@CleanUpPartitionsFlag = 0,
'INSERT INTO [' + @DatabaseNameDW + '].[' + @DWSchema + '].['+ @DWTable + '_Temp] WITH (TABLOCK)
(
'   + ISNULL(@IDType2Columns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	DWCreatedDate
	,DWModifiedDate
)  

SELECT 
	' + ISNULL(@IDType2Merge,'')
	  + ISNULL(@IDMerge,'')
	  + ISNULL(@Select ,'')
	  + '@UpdateDateTime AS DWCreatedDate ' + @CRLF + ', @UpdateDateTime AS DWModifiedDate
FROM [' + @DatabaseNameStage + '].[' + @StageSchema + '].['+ @StageTable + '] AS ' + @StageTable + ' ' + @CRLF +
ISNULL(@LeftJoinType2,'') + 
ISNULL(@LeftJoin,'')
,'') + @CRLF + @CRLF +

'COMMIT TRAN
END TRY
BEGIN CATCH
		IF @@TRANCOUNT > 0		
			ROLLBACK TRAN; --RollBack in case of Error
		THROW;  
END CATCH'



SET @SQL = CASE 
				WHEN @IncrementalFact = 0 OR @LoadPattern = 'FactFull' THEN @SQLFullLoad
				WHEN @IncrementalFact = 1 AND @LoadPattern = 'FactMerge' THEN CONCAT(@SQLStandard,@SQLMergeJoin)
				WHEN @IncrementalFact = 1 AND @LoadPattern = 'FactAdd' THEN @SQLAdd
				WHEN @IncrementalFact = 1 AND @LoadPattern = 'FactDelta' THEN @SQLDelta
				WHEN @IncrementalFact = 1 AND @LoadPattern = 'FactReplacement' THEN @SQLReplacement
		   END
		   
IF @PrintSQL = 0
BEGIN

	EXEC(@SQL)

END
ELSE
BEGIN

	SELECT 
		CAST('<?SQL --'
			+@CRLF
			+ISNULL(@SQL,'')
			+@CRLF
			+ '-- ?>' AS XML) SQLScript

END
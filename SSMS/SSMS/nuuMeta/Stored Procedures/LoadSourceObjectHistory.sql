
CREATE PROCEDURE [nuuMeta].[LoadSourceObjectHistory] 

	@ExtractTable  NVARCHAR(200),--Input is the extract table with schema
	@LoadIsIncremental BIT,
	@HistoryTrackingColumns NVARCHAR(MAX), --Input is the SDC2 columns comma separated
	@PrintSQL BIT = 0

AS

/*
DECLARE 
	@ExtractTable NVARCHAR(200) = 'sourceNuudlColumbus.AFTALE_LID',
	@LoadIsIncremental BIT = 1,
	@HistoryTrackingColumns NVARCHAR(MAX) = '', 
	@PrintSQL BIT = 1
--*/

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/

DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10) 
DECLARE @TableSchema NVARCHAR(100) = LEFT(@ExtractTable,CHARINDEX('.',@ExtractTable,0)-1)
DECLARE @Table NVARCHAR(100) = REPLACE(REPLACE(REPLACE(@ExtractTable,CONCAT(@TableSchema,'.'),''),'[',''),']','')
DECLARE @DatabaseNameExtract NVARCHAR(128) = (SELECT VariableValue FROM nuuMetaView.Variables WHERE VariableName = 'DatabaseNameExtract')
DECLARE @DatabaseNameMeta NVARCHAR(128) = (SELECT VariableValue FROM nuuMetaView.Variables WHERE VariableName = 'DatabaseNameMeta')
DECLARE @DatabaseNameHistory NVARCHAR(128) = (SELECT VariableValue FROM nuuMetaView.Variables WHERE VariableName = 'DatabaseNameHistory')
DECLARE @IsCloudFlag NVARCHAR(128) = (SELECT VariableValue FROM nuuMetaView.Variables WHERE VariableName = 'IsCloudFlag')
DECLARE @SeparateHistoryFlag NVARCHAR(128) = (SELECT VariableValue FROM nuuMetaView.Variables WHERE VariableName = 'SeparateHistoryLayerFlag')
DECLARE @HistoryTable NVARCHAR(100) = IIF(@SeparateHistoryFlag = 1 AND @IsCloudFlag = 1,@Table,@Table + '_History')
DECLARE @HistorySchema NVARCHAR(50) = IIF(@SeparateHistoryFlag = 1 AND @IsCloudFlag = 1,@TableSchema + '_history',@TableSchema)
DECLARE @DatabaseCollation NVARCHAR(100) = (SELECT CONVERT (varchar, DATABASEPROPERTYEX('' + @DatabaseNameMeta + '','collation')))

/**********************************************************************************************************************************************************************
1. Create and insert data into table variables
**********************************************************************************************************************************************************************/
DROP TABLE IF EXISTS #InformationSchema
CREATE TABLE #InformationSchema (TableName NVARCHAR(128), ColumnName NVARCHAR(MAX), OrdinalPosition INT, PrimaryKey INT, Type2_COLUMN BIT)

/*Generates the combined information schema*/
INSERT #InformationSchema (TableName, ColumnName, OrdinalPosition, PrimaryKey, Type2_COLUMN)
SELECT
	COLUMNS.TABLE_NAME,
	COLUMNS.COLUMN_NAME,
	COLUMNS.ORDINAL_POSITION,
	CASE
		WHEN KEY_COLUMN_USAGE.COLUMN_NAME IS NULL THEN 0
		ELSE 1
	END AS PRIMARY_KEY,
	CASE	
		WHEN COLUMNS.COLUMN_NAME COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS IN (SELECT [value] FROM STRING_SPLIT(@HistoryTrackingColumns,','))  
			OR @HistoryTrackingColumns = '*' THEN 1
		ELSE 0
	END Type2_COLUMN
FROM INFORMATION_SCHEMA.COLUMNS
LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE
	ON COLUMNS.TABLE_NAME = KEY_COLUMN_USAGE.TABLE_NAME
		AND COLUMNS.COLUMN_NAME = KEY_COLUMN_USAGE.COLUMN_NAME
		AND COLUMNS.TABLE_SCHEMA = KEY_COLUMN_USAGE.TABLE_SCHEMA
WHERE
	COLUMNS.TABLE_NAME = @Table
	AND COLUMNS.TABLE_SCHEMA = @TableSchema
	AND COLUMNS.COLUMN_NAME NOT LIKE 'DW%'


/**********************************************************************************************************************************************************************
2. Create Loop counter and support variables
**********************************************************************************************************************************************************************/

DECLARE @NonKeyColumns INT

SELECT 
	@NonKeyColumns = (SELECT COUNT(ColumnName) FROM #InformationSchema WHERE PrimaryKey = 0)

/**********************************************************************************************************************************************************************
3. Create Merge Keys part and Merge Ouput part
**********************************************************************************************************************************************************************/

DECLARE @Keys NVARCHAR(MAX) --Holds the value of @Keys for each loop
DECLARE @MergeOutput NVARCHAR(MAX) --Holds the value of @MergeOutput for each loop

SELECT
	@Keys = STRING_AGG('[source].[' + ColumnName + '] = [target].[' + ColumnName + ']', ' AND '),
	@MergeOutput = STRING_AGG('MERGE_OUTPUT.[' + ColumnName + '] IS NOT NULL', ' AND ')
FROM #InformationSchema
WHERE PrimaryKey = 1

/**********************************************************************************************************************************************************************
4. Create columns from extract and output column part
**********************************************************************************************************************************************************************/

DECLARE @ColumnNameExtract NVARCHAR(MAX) --Holds the value of @ColumnNameExtract for each loop
DECLARE @Output NVARCHAR(MAX) --Holds the value of @ColumnNameDim for each loop

SELECT
	@ColumnNameExtract = STRING_AGG('[' + ColumnName + ']',', '),
	@Output = STRING_AGG('[source].[' + ColumnName + '] AS [' + ColumnName + ']', ', ')
FROM #InformationSchema

/**********************************************************************************************************************************************************************
5.Create update part and match part for Type1 columns
**********************************************************************************************************************************************************************/

DECLARE @UpdateType1 NVARCHAR(MAX) --Holds the value of @ColumnNameDim for each loop
DECLARE @MatchType1 NVARCHAR(MAX) --Holds the value of @ColumnNameDim for each loop

SELECT
	@MatchType1 = STRING_AGG('([target].[' + ColumnName + '] <> [source].[' + ColumnName + ']) OR ([target].[' + ColumnName + '] IS NULL AND [source].[' + ColumnName + '] IS NOT NULL) OR ([target].[' + ColumnName + '] IS NOT NULL AND [source].[' + ColumnName + '] IS NULL)', ' OR '),
	@UpdateType1 = STRING_AGG('[target].[' + ColumnName + '] = [source].[' + ColumnName + ']', ', ')
FROM #InformationSchema AS InformationSchema
WHERE
	Type2_Column = 0
	AND PrimaryKey = 0 

/**********************************************************************************************************************************************************************
6.Create match part for Type2 columns
**********************************************************************************************************************************************************************/

DECLARE @MatchType2 NVARCHAR(MAX) --Holds the value of @ColumnNameDim for each loop

SELECT
	@MatchType2 = STRING_AGG('([target].[' + ColumnName + '] <> [source].[' + ColumnName + '] OR ([target].[' + ColumnName + '] IS NULL AND [source].[' + ColumnName + '] IS NOT NULL) OR ([target].[' + ColumnName + '] IS NOT NULL AND [source].[' + ColumnName + '] IS NULL))', ' OR ')
FROM #InformationSchema
WHERE Type2_Column = 1
	 AND PrimaryKey = 0


/**********************************************************************************************************************************************************************
7. Fill out the dynamic SQL script variables
**********************************************************************************************************************************************************************/

DECLARE @Parameters NVARCHAR(MAX) --Holds the parameter part of the Merge Join Script
DECLARE @Type1 NVARCHAR(MAX) --Holds the Type1 part of the Merge Join Script
DECLARE @Type2 NVARCHAR(MAX) --Holds the Type2 part of the Merge Join Script
DECLARE @FullScript NVARCHAR(MAX) --Combining @Parameters, @Type1, @Type2
DECLARE @DeleteSQL NVARCHAR(MAX)
DECLARE @ValidFrom NVARCHAR(4000) 
DECLARE @ValidTo NVARCHAR(4000)  
DECLARE @IsCurrent NVARCHAR(4000) 

/* Inherit values from NuuDL  */
SELECT 
	@ValidFrom = ISNULL(MAX(CASE WHEN ColumnName = 'NUUDL_ValidFrom' THEN '['+ColumnName+']' END),'@MinDateTime'),
	@ValidTo = ISNULL(MAX(CASE WHEN ColumnName = 'NUUDL_ValidTo' THEN '['+ColumnName+']' END),'@MaxDateTime'),
	@IsCurrent = ISNULL(MAX(CASE WHEN ColumnName = 'NUUDL_PKLatest' THEN '['+ColumnName+']' END),'@BooleanTrue')
FROM #InformationSchema 


SET @Parameters =
'DECLARE @CurrentDateTime datetime
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


SET @Type1 = 

'
-- ==================================================
-- Type1
-- ==================================================

MERGE [' + @HistorySchema + '].['+ @HistoryTable + '] as [target] USING
	[' + @TableSchema + '].[' + @Table + '] as [source]

-- Selects source rows in order to compare them to [target]

ON
(
' + @Keys + '
)

WHEN NOT MATCHED BY TARGET THEN

INSERT 
(
' + @ColumnNameExtract + 
',[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeletedInSource]
,[DWDeletedInSourceDate]

)

VALUES 
(
' + @ColumnNameExtract + '
,'+@IsCurrent+'
,'+@ValidFrom+'
,'+@ValidTo+'
,@CurrentDateTime
,@CurrentDateTime
,@BooleanFalse
,@MinDateTime

)
'
+ CASE WHEN @NonKeyColumns = 0 THEN '' ELSE 'WHEN MATCHED AND 
(
' + @MatchType1 +')

THEN UPDATE

SET 
'+  @UpdateType1 + ', [target].[DWModifiedDate] = @CurrentDateTime

' END 
+ CASE WHEN @LoadIsIncremental = 1 THEN '' ELSE '

WHEN NOT MATCHED BY SOURCE 

THEN UPDATE

SET
 [target].[DWValidToDate] = IIF([target].[DWValidToDate] = [target].[DWDeletedInSourceDate] AND [target].[DWIsDeletedInSource] = @BooleanTrue, @MaxDateTime, IIF([target].[DWIsCurrent] = @BooleanTrue AND [target].[DWIsDeletedInSource] = @BooleanFalse,@CurrentDateTime,[target].[DWValidToDate]))
,[target].[DWModifiedDate] = IIF([target].[DWIsCurrent] = @BooleanTrue AND [target].[DWIsDeletedInSource] = @BooleanFalse,@CurrentDateTime,[target].[DWModifiedDate])
,[target].[DWDeletedInSourceDate] =	IIF([target].[DWValidToDate] = @MaxDateTime AND [target].[DWIsDeletedInSource] = @BooleanFalse, @CurrentDateTime,[target].[DWDeletedInSourceDate])	
,[target].[DWIsCurrent] = IIF([target].[DWValidToDate] = @MaxDateTime , @BooleanTrue, @BooleanFalse)

' END + ';



-- ==================================================
-- History on deleted records
-- ==================================================

INSERT INTO [' + @HistorySchema + '].[' + @HistoryTable +']
(' + @ColumnNameExtract + 
',[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeletedInSource]
,[DWDeletedInSourceDate]

)
SELECT 
' + @ColumnNameExtract + 
',@BooleanFalse
,@CurrentDateTime
,@MaxDateTime
,@CurrentDateTime
,@CurrentDateTime
,@BooleanTrue
,[DWDeletedInSourceDate]

FROM
	[' + @HistorySchema + '].[' + @HistoryTable +'] as [target]
WHERE 
	CAST(DWDeletedInSourceDate as date) = CAST(@CurrentDateTime as date)
	AND NOT EXISTS (SELECT * FROM [' + @TableSchema + '].[' + @Table + '] [source] WHERE ' + @Keys + ')  
	AND DWIsDeletedInSource = 0
	AND DATEDIFF_BIG(SECOND, [DWValidToDate], GETDATE()) < 60
'

SET @Type2 =
'

-- ==================================================
-- Type2
-- ==================================================

INSERT INTO [' + @HistorySchema + '].[' + @HistoryTable +']
(' + @ColumnNameExtract + 
',[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeletedInSource]
,[DWDeletedInSourceDate]

)
SELECT 
' + @ColumnNameExtract + 
',[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeletedInSource]
,[DWDeletedInSourceDate]

FROM
(
MERGE [' + @HistorySchema + '].[' + @HistoryTable +'] as [target]
USING
(
SELECT 
' + @ColumnNameExtract + 'FROM  [' + @TableSchema + '].[' + @Table + ']
	) as [source]
	
ON
(
' + @Keys + '
)

WHEN NOT MATCHED BY TARGET

THEN INSERT
(' + @ColumnNameExtract + 
',[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeletedInSource]
,[DWDeletedInSourceDate]
)

VALUES
(' + @ColumnNameExtract + '
,'+@IsCurrent+'
,'+@ValidFrom+'
,'+@ValidTo+'
,@CurrentDateTime
,@CurrentDateTime
,@BooleanFalse
,@MinDateTime

	)
'  
+ CASE WHEN @LoadIsIncremental = 1 THEN '' ELSE '

WHEN NOT MATCHED BY SOURCE 

THEN UPDATE

SET
 [target].[DWValidToDate] = IIF([target].[DWIsCurrent] = @BooleanTrue AND [target].[DWIsDeletedInSource] = @BooleanFalse,@CurrentDateTime,[target].[DWValidToDate])
,[target].[DWModifiedDate] = IIF([target].[DWIsCurrent] = @BooleanTrue AND [target].[DWIsDeletedInSource] = @BooleanFalse,@CurrentDateTime,[target].[DWModifiedDate])
,[target].[DWIsCurrent] = @BooleanFalse
--,[target].[DWIsDeletedInSource] = @BooleanTrue
--,[target].[DWDeletedInSourceDate] = IIF([target].[DWIsDeletedInSource] = @BooleanFalse,@CurrentDateTime,[target].[DWDeletedInSourceDate])

' END +
'
WHEN MATCHED AND
(
([DWIsCurrent] = @BooleanTrue OR ([DWIsCurrent] IS NULL AND @BooleanTrue IS NULL)) 
)
AND
( ' + @MatchType2 + ' ) 
OR ([DWIsDeletedInSource] = @BooleanTrue AND [DWValidFromDate] < @CurrentDateTime AND DWValidToDate = @MaxDateTime)

THEN UPDATE
SET  	[DWIsCurrent] = @BooleanFalse,
		[DWValidToDate] = @DateToDateTime
	
OUTPUT $Action as [MERGE_ACTION_942b9586-8926-4710-a7b0-9eb75b98f9b0],
' + @Output + ',
'+@IsCurrent+' AS [DWIsCurrent], 
'+@ValidFrom+' AS [DWValidFromDate],
'+@ValidTo+' AS [DWValidToDate],
@CurrentDateTime AS [DWCreatedDate],
@CurrentDateTime AS [DWModifiedDate],
@BooleanFalse AS [DWIsDeletedInSource],
@MinDateTime AS [DWDeletedInSourceDate]

)MERGE_OUTPUT
WHERE MERGE_OUTPUT.[MERGE_ACTION_942b9586-8926-4710-a7b0-9eb75b98f9b0] = ''UPDATE''
	AND ' + @MergeOutput + '
;
'

SET @FullScript = IIF(@MatchType1 IS NULL AND @MatchType2 IS NULL,'',CONCAT(@Parameters,CASE WHEN @MatchType1 IS NULL THEN NULL ELSE @Type1 END,CASE WHEN @MatchType2 IS NULL THEN NULL ELSE @Type2 END))
SET @DeleteSQL =  IIF(@MatchType1 IS NULL AND @MatchType2 IS NULL,'DELETE target WITH (TABLOCK) 
FROM [' + @DatabaseNameHistory + '].[' + @HistorySchema + '].['+ @HistoryTable + '] AS [target] 
INNER JOIN [' + @DatabaseNameExtract + '].[' + @TableSchema + '].[' + @Table + '] AS [source] 
ON ' + @Keys + @CRLF ,'')


/**********************************************************************************************************************************************************************
9. Execute dynamic SQL script variables
**********************************************************************************************************************************************************************/

IF @PrintSQL = 0

	BEGIN

		EXEC(@FullScript)
		EXEC(@DeleteSQL)

	END

ELSE

	BEGIN

		SELECT 
		CAST('<?SQL --'
			+@CRLF
			+ISNULL(@FullScript,'')
			+ISNULL(@DeleteSQL,'')
			+@CRLF
			+ '-- ?>' AS XML) SQLScript

	END

SET NOCOUNT OFF
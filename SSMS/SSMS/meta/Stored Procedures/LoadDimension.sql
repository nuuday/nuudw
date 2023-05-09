

/**********************************************************************************************************************************************************************
The purpose of this scripts is to create and execute the merge join statement between stage tables and dimensions. The script has the following charateristics:
- All columns is by default treated as SCD1.
- If a column is entered into the table etl.BusinessMatrixSCDSetup the column is treated as SCD2
- NULL values is changed to the default value entered ind the table application.Variables 
- The dimension unknown value is dropped and re-created to make sure there is no empty columns
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [meta].[LoadDimension]

@Table  NVARCHAR(100), --Input is the dimensions name without schema
@LoadIsIncremental BIT,
@DisableMaintainDWFlag BIT,
@PrintSQL BIT

AS

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/
DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10) --Linebreak
DECLARE @DatabaseNameStage NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameStage')
DECLARE @DatabaseNameDW NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameDW')
DECLARE @SurrogateKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'SurrogateKeySuffix')
DECLARE @BusinessKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'BusinessKeySuffix')
DECLARE @FactEngineIsSQLFlag BIT = IIF((SELECT VariableValue FROM meta.Variables WHERE VariableName = 'FactLoadEngine') = 'SQL',1,0)
DECLARE @IsCloudFlag BIT = IIF((SELECT VariableValue FROM meta.Variables WHERE VariableName = 'IsCloudFlag') = '1',1,0)
DECLARE @StageSchemaTable TABLE (SchemaName NVARCHAR(10)) 
INSERT @StageSchemaTable EXEC('SELECT DISTINCT TABLE_SCHEMA FROM [' + @DatabaseNameStage + '].INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @Table + ''' AND TABLE_SCHEMA IN (''dbo'',''stage'')')
DECLARE @StageSchema NVARCHAR(10) = (SELECT IIF(@IsCloudFlag = 1,'stage',(SELECT SchemaName FROM @StageSchemaTable))) --If on-premise and stageschema has not been changed

/**********************************************************************************************************************************************************************
Execute MaintainDW if LoadEngine is SQL
***********************************************************************************************************************************************************************/
IF @IsCloudFlag = 1 AND @DisableMaintainDWFlag = 0
	BEGIN
		EXEC meta.MaintainDW @MasterTable = @Table, @MasterDestinationSchema = 'dim'
		WAITFOR DELAY '00:00:02' --To prevent deadlock when running the procedure in parallel
	END

/**********************************************************************************************************************************************************************
1. Create and insert data into table variables
**********************************************************************************************************************************************************************/

DECLARE @InformationSchema TABLE (DatabaseName NVARCHAR(128), TableName NVARCHAR(128), ColumnName NVARCHAR(128), OrdinalPosition INT, DataType NVARCHAR(128))
DECLARE @SCD2Columns TABLE (SCD2Columns NVARCHAR(500))
DECLARE @ColumnDefaults TABLE (DataType NVARCHAR(50),DefaultValue NVARCHAR(250))

/*Generates a dataset with the combined information schema*/
INSERT @InformationSchema EXEC(
							'SELECT 
								 ''Stage'' AS DatabaseName
								,TABLE_NAME
								,COLUMN_NAME
								,ORDINAL_POSITION
								,DATA_TYPE
							 FROM 
								[' + @DatabaseNameStage + '].INFORMATION_SCHEMA.COLUMNS
							 WHERE 
								TABLE_NAME = ''' + @Table + ''' 
								AND COLUMN_NAME NOT LIKE ''DW%'' 
								AND	TABLE_SCHEMA = ''' + @StageSchema + '''


							 UNION ALL

							 SELECT  
								 ''DW'' AS DatabaseName
								,TABLE_NAME
								,COLUMN_NAME
								,ORDINAL_POSITION
								,DATA_TYPE
							 FROM 
								[' + @DatabaseNameDW + '].INFORMATION_SCHEMA.COLUMNS
							 WHERE 
								TABLE_NAME = ''' + @Table + ''' 
								AND	TABLE_SCHEMA = ''dim'''
						)

/*Generates a dataset with the SCD2 columns*/
INSERT @SCD2Columns	EXEC('  SELECT DISTINCT
								all_columns.name 
							FROM
								[' + @DatabaseNameDW + '].sys.tables
							INNER JOIN 
								[' + @DatabaseNameDW + '].sys.schemas
									ON schemas.schema_id = tables.schema_id
							INNER JOIN 
								[' + @DatabaseNameDW + '].sys.all_columns 
									ON all_columns.object_id=tables.object_id
							INNER JOIN 
								[' + @DatabaseNameDW + '].sys.extended_properties
									ON extended_properties.major_id=tables.object_id 
									AND extended_properties.minor_id=all_columns.column_id 
									AND extended_properties.class=1
							WHERE
								extended_properties.name = ''SCDColumn''
								AND schemas.name = ''dim''
								AND tables.name = ''' + @Table + '''')

/*Generates a dataset with the column default values*/
INSERT @ColumnDefaults EXEC('SELECT REPLACE([name],''Default'','''') AS DataType
								   ,CONVERT(NVARCHAR(128),value) AS DefaultValue
							 FROM 
								sys.extended_properties
							 WHERE 
								[name] IN (''DefaultDate'',''DefaultDimensionMemberID'',''DefaultNumber'',''DefaultString'',''DefaultBit'')')


/**********************************************************************************************************************************************************************
2. Create Loop counter variables and SCD2HistoryVariable
**********************************************************************************************************************************************************************/

DECLARE @Counter INT --Just a counter
DECLARE @NumberOfColumnsStage INT --Number of columns from stage
DECLARE @NumberOfColumnsDim INT --Number of columns from dim
DECLARE @NumberOfColumnsSCD1 INT --Number of SCD1 columns
DECLARE @NumberOfColumnsNonKeySCD1 INT --Number of SCD1 nonkey columns
DECLARE @NumberOfColumnsSCD2 INT --Number of SCD2 columns
DECLARE @NumberOfKeyColumns INT --Number of key columns
DECLARE @SCD2HistoryFromSourceKey NVARCHAR(MAX) --If the dimension has the following columns DimensionNameIsCurrent, DimensionNameValidFromDate and DimensionNameValidToDate SCD2 history is created in the source

SELECT 
	@Counter = 1,
	@NumberOfKeyColumns = (SELECT MAX(OrdinalPosition) FROM @InformationSchema WHERE DatabaseName = 'Stage' AND ColumnName LIKE '%' + @BusinessKeySuffix),
	@NumberOfColumnsStage = (SELECT MAX(OrdinalPosition) FROM @InformationSchema WHERE DatabaseName = 'Stage'),
	@NumberOfColumnsDim =  (SELECT MAX(OrdinalPosition) FROM @InformationSchema WHERE DatabaseName = 'DW'),
	@NumberOfColumnsSCD1 = (SELECT MAX(OrdinalPosition) FROM @InformationSchema AS InformationSchema LEFT JOIN @SCD2Columns AS SCD ON SCD.SCD2Columns = InformationSchema.ColumnName WHERE DatabaseName = 'Stage' AND SCD.SCD2Columns IS NULL),
	@NumberOfColumnsNonKeySCD1 = (SELECT MAX(OrdinalPosition) FROM @InformationSchema AS InformationSchema LEFT JOIN @SCD2Columns AS SCD ON SCD.SCD2Columns = InformationSchema.ColumnName WHERE DatabaseName = 'Stage' AND SCD.SCD2Columns IS NULL AND InformationSchema.ColumnName NOT LIKE '%' + @BusinessKeySuffix),
	@NumberOfColumnsSCD2 = (SELECT MAX(OrdinalPosition) FROM @InformationSchema AS InformationSchema INNER JOIN @SCD2Columns SCD ON SCD.SCD2Columns = InformationSchema.ColumnName WHERE DatabaseName = 'Stage'),
	@SCD2HistoryFromSourceKey = (SELECT IIF(COUNT(ColumnName) = 3, ' AND [source].[' + @Table + 'ValidFromDate] = [target].[' + @Table + 'ValidFromDate]', NULL) FROM @InformationSchema WHERE REPLACE(ColumnName,@Table,'') IN ('IsCurrent', 'ValidFromDate', 'ValidToDate') AND DatabaseName = 'Stage' )


/**********************************************************************************************************************************************************************
3. Create Merge Keys part and Merge Ouput part
**********************************************************************************************************************************************************************/

DECLARE @PlaceholderKeys NVARCHAR(MAX) --Placeholder used in the loop generating the business keys used in the Merge Join script
DECLARE @Keys NVARCHAR(MAX) --Holds the value of @PlaceholderKeys for each loop
DECLARE @PlaceholderMergeOutput NVARCHAR(MAX) --Placeholder for the MergeOutput part of the script
DECLARE @MergeOutput NVARCHAR(MAX) --Holds the value of @PlaceholderMergeOutput for each loop

WHILE @Counter <= @NumberOfKeyColumns BEGIN

	SELECT 
		@PlaceholderKeys = '[source].[' + ColumnName + '] = [target].[' + ColumnName + ']'  + CASE WHEN @Counter != @NumberOfKeyColumns THEN ' AND ' ELSE '' END,
		@PlaceholderMergeOutput = 'MERGE_OUTPUT.[' + ColumnName + '] IS NOT NULL'  + CASE WHEN @Counter != @NumberOfKeyColumns THEN ' AND ' ELSE '' END  
	FROM 
		@InformationSchema 
	WHERE 
		DatabaseName = 'Stage' and
		ColumnName LIKE '%' + @BusinessKeySuffix and
		OrdinalPosition = @Counter

	SET @Keys = CONCAT(@Keys,@PlaceholderKeys)
	SET @MergeOutput = CONCAT(@MergeOutput,@PlaceholderMergeOutput)

	SET @PlaceholderKeys = ''
	SET @PlaceholderMergeOutput = ''

	SET @Counter = @Counter + 1

END

SET @Keys = @Keys + ISNULL(@SCD2HistoryFromSourceKey,'') --If SCD2 history is created in source ValidFromDate is used as key

SET @Counter = 1

/**********************************************************************************************************************************************************************
4. Create Column from Source part which handles null values, columns from stage and output column part
**********************************************************************************************************************************************************************/

DECLARE @PlaceholderColumnNameStage NVARCHAR(MAX) 
DECLARE @ColumnNameStage NVARCHAR(MAX) 
DECLARE @PlaceholderColumnNameSource NVARCHAR(MAX) 
DECLARE @ColumnNameSource NVARCHAR(MAX) 
DECLARE @PlaceholderOutput NVARCHAR(MAX) 
DECLARE @Output NVARCHAR(MAX) 

WHILE @Counter <= @NumberOfColumnsStage BEGIN 

	SELECT 
		@PlaceholderColumnNameSource = 
			CASE 
				WHEN DataType LIKE '%char%' AND ColumnName NOT LIKE '%' + @BusinessKeySuffix AND ColumnName NOT LIKE '%Code'
				THEN 'ISNULL([' + ColumnName + '],''' + (SELECT DefaultValue FROM @ColumnDefaults WHERE DataType = 'String') + ''') AS [' + ColumnName + ']'
				WHEN DataType IN ('int','tinyint','bigint','smallint','decimal','numeric','float','double','money') AND ColumnName NOT LIKE '%' + @BusinessKeySuffix AND ColumnName NOT LIKE '%Code'
				THEN 'ISNULL([' + ColumnName + '],''' + (SELECT DefaultValue FROM @ColumnDefaults WHERE DataType = 'Number') + ''') AS [' + ColumnName + ']'
				WHEN DataType LIKE '%date%' AND ColumnName NOT LIKE '%' + @BusinessKeySuffix AND ColumnName NOT LIKE '%Code'
				THEN 'ISNULL([' + ColumnName + '],''' + (SELECT DefaultValue FROM @ColumnDefaults WHERE DataType = 'Date') + ''') AS [' + ColumnName + ']'
				WHEN DataType = 'bit' AND ColumnName NOT LIKE '%' + @BusinessKeySuffix AND ColumnName NOT LIKE '%Code'
				THEN 'ISNULL([' + ColumnName + '],''' + (SELECT DefaultValue FROM @ColumnDefaults WHERE DataType = 'Bit') + ''') AS [' + ColumnName + ']'
				WHEN ColumnName LIKE '%Code'
				THEN 'ISNULL([' + ColumnName + '],''' + (SELECT DefaultValue FROM @ColumnDefaults WHERE DataType = 'DimensionMemberID') + ''') AS [' + ColumnName + ']'
				ELSE '[' + ColumnName + ']' 
			END + 
			CASE 
				WHEN @Counter != @NumberOfColumnsStage 
				THEN ',' 
				ELSE '' 
			END + @CRLF,
		@PlaceholderColumnNameStage = 
			'[' + ColumnName + ']' + 
			CASE 
				WHEN @Counter != @NumberOfColumnsStage 
				THEN ',' 
				ELSE '' 
			END + @CRLF,
		@PlaceholderOutput = 
			'[source].[' + ColumnName + '] AS [' + ColumnName +']' + 
			CASE 
				WHEN @Counter != @NumberOfColumnsStage 
				THEN ', ' 
				ELSE '' 
			END + @CRLF    
	FROM 
		@InformationSchema
	WHERE 
		DatabaseName = 'Stage' and
		OrdinalPosition = @Counter

	SET @ColumnNameSource = CONCAT(@ColumnNameSource,@PlaceholderColumnNameSource)
	SET @PlaceholderColumnNameSource = ''
	SET @ColumnNameStage = CONCAT(@ColumnNameStage,@PlaceholderColumnNameStage)
	SET @PlaceholderColumnNameStage = ''
	SET @Output = CONCAT(@Output,@PlaceholderOutput)
	SET @PlaceholderOutput = ''
	SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
5.Create update part and match part for SCD1 columns
**********************************************************************************************************************************************************************/

DECLARE @PlaceholderUpdateSCD1 NVARCHAR(MAX) 
DECLARE @UpdateSCD1 NVARCHAR(MAX) 
DECLARE @PlaceholderMatchSCD1 NVARCHAR(MAX) 
DECLARE @MatchSCD1 NVARCHAR(MAX) 

WHILE @Counter <= @NumberOfColumnsStage BEGIN 

	SELECT 
		@PlaceholderMatchSCD1 =  
			'([target].[' + ColumnName + '] <> [source].[' + ColumnName + ']) OR ([target].[' + ColumnName + '] IS NULL AND [source].[' + ColumnName + '] IS NOT NULL) OR ([target].[' + ColumnName + '] IS NOT NULL AND [source].[' + ColumnName + '] IS NULL)' + 
			CASE 
				WHEN @Counter != @NumberOfColumnsNonKeySCD1 
				THEN ' OR ' 
				ELSE '' 
			END +  @CRLF ,
		@PlaceholderUpdateSCD1 = 
			'[target].[' + ColumnName + '] = [source].[' + ColumnName + '],' +  @CRLF
	FROM 
		@InformationSchema AS InformationSchema 
	LEFT JOIN 
		@SCD2Columns AS SCD ON 
			SCD.SCD2Columns = InformationSchema.ColumnName
	WHERE 
		DatabaseName = 'Stage' and
		OrdinalPosition = @Counter and
		SCD.SCD2Columns IS NULL and 
		ColumnName NOT LIKE '%' + @BusinessKeySuffix

	SET @MatchSCD1 = CONCAT(@MatchSCD1,@PlaceholderMatchSCD1)
	SET @PlaceholderMatchSCD1 = ''
	SET @UpdateSCD1 = CONCAT(@UpdateSCD1,@PlaceholderUpdateSCD1)
	SET @PlaceholderUpdateSCD1 = ''
	SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
6.Create match part for SCD2 columns
**********************************************************************************************************************************************************************/

DECLARE @PlaceholderMatchSCD2 NVARCHAR(MAX) 
DECLARE @MatchSCD2 NVARCHAR(MAX) 

WHILE @Counter <= @NumberOfColumnsStage BEGIN 

	SELECT 
		@PlaceholderMatchSCD2 =  
			'([target].[' + ColumnName + '] <> [source].[' + ColumnName + '] OR ([target].[' + ColumnName + '] IS NULL AND [source].[' + ColumnName + '] IS NOT NULL) OR ([target].[' + ColumnName + '] IS NOT NULL AND [source].[' + ColumnName + '] IS NULL))' + 
			CASE 
				WHEN @Counter != @NumberOfColumnsSCD2 
				THEN ' OR ' 
				ELSE '' 
			END + @CRLF
	FROM 
		@InformationSchema AS InformationSchema 
	INNER JOIN
		@SCD2Columns AS SCD on
			SCD.SCD2Columns = InformationSchema.ColumnName
	WHERE 
		DatabaseName = 'Stage' and
		OrdinalPosition = @Counter

	SET @MatchSCD2 = CONCAT(@MatchSCD2,@PlaceholderMatchSCD2)
	SET @PlaceholderMatchSCD2 = ''
	SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
7. Create columns for insert unknown value
**********************************************************************************************************************************************************************/

DECLARE @PlaceholderColumnUnknownValue NVARCHAR(MAX) 
DECLARE @ColumnUnknownValue NVARCHAR(MAX) 

WHILE @Counter <= @NumberOfColumnsDim BEGIN 

	SELECT 
		@PlaceholderColumnUnknownValue =
			',''' + 
			CASE 
				WHEN ColumnDefaults.DefaultValue IS NOT NULL THEN ColumnDefaults.DefaultValue								
				WHEN InformationSchema.DataType = 'uniqueidentifier' THEN 'GUID'                                           
				ELSE ''
			END + '''' + @CRLF 
	FROM 
		@InformationSchema AS InformationSchema LEFT JOIN 
		@ColumnDefaults AS ColumnDefaults ON 
			ColumnDefaults.DataType = 
			CASE 
				WHEN InformationSchema.DataType LIKE 'Date%' THEN 'Date' 
				WHEN InformationSchema.DataType LIKE '%char%' THEN 'String'
				WHEN InformationSchema.DataType = 'bit'THEN 'Bit' 
				WHEN ColumnName LIKE '%Key' OR ColumnName LIKE '%Code' THEN 'DimensionMemberID'
				WHEN InformationSchema.DataType = 'uniqueidentifier' THEN 'GUID' 
				ELSE 'Number'
			END
	WHERE 
		DatabaseName = 'Stage' AND 
		OrdinalPosition = @Counter

	SET @ColumnUnknownValue = CONCAT(@ColumnUnknownValue,@PlaceholderColumnUnknownValue)
	SET @PlaceholderColumnUnknownValue = ''
	SET @Counter = @Counter + 1

END

/**********************************************************************************************************************************************************************
8. Fill out the dynamic SQL script variables
**********************************************************************************************************************************************************************/

DECLARE @InsertUnknownScript NVARCHAR(MAX) 
DECLARE @ParametersScript NVARCHAR(MAX) 
DECLARE @SCD1Script NVARCHAR(MAX)
DECLARE @SCD2Script NVARCHAR(MAX) 
DECLARE @SCDFullScript NVARCHAR(MAX) 

-- Insert unknown
SET @InsertUnknownScript = '
SET IDENTITY_INSERT [' + @DatabaseNameDW + '].[dim].[' + @Table + '] ON

DELETE FROM [' + @DatabaseNameDW + '].[dim].[' + @Table + '] WHERE ' + @Table + @SurrogateKeySuffix + ' = ' + (SELECT DefaultValue FROM @ColumnDefaults WHERE DataType = 'DimensionMemberID') + '
INSERT [' + @DatabaseNameDW + '].[dim].[' + @Table + '] (' + @CRLF +
	'[' + @Table + @SurrogateKeySuffix + '],' + @CRLF  +
	@ColumnNameStage + '
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
)
SELECT ' + 
	(SELECT DefaultValue FROM @ColumnDefaults WHERE DataType = 'DimensionMemberID') + @CRLF +
	 REPLACE(@ColumnUnknownValue, '''GUID''','NEWID()') + '
	,1
	,''1900-01-01''
	,''9999-12-31''
	,GETDATE()
	,GETDATE()
	,0

SET IDENTITY_INSERT [' + @DatabaseNameDW + '].[dim].[' + @Table + '] OFF
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
	@DateToDateTime = dateadd(ms,-3,  getdate())
'

-- SCD 1
SET @SCD1Script = 

'
-- ==================================================
-- SCD1
-- ==================================================

MERGE [' + @DatabaseNameDW + '].[dim].['+ @Table + '] as [target] USING
(

SELECT 
' + @ColumnNameSource + 'FROM [' + @DatabaseNameStage + '].[' + @StageSchema + '].[' + @Table + '] 

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
+ CASE WHEN @NumberOfColumnsNonKeySCD1 IS NULL THEN '' ELSE 'WHEN MATCHED AND 
(
' + @MatchSCD1 +')

THEN UPDATE

SET 
'+  @UpdateSCD1 + '[target].[DWModifiedDate] = @CurrentDateTime
' END

+ CASE WHEN @LoadIsIncremental = 1 THEN '' ELSE '
WHEN NOT MATCHED BY SOURCE AND 
[target].[' + @Table + @SurrogateKeySuffix + '] > 0
AND 
(
([DWIsCurrent] = @BooleanTrue OR ([DWIsCurrent] IS NULL AND @BooleanTrue IS NULL))
)
THEN UPDATE

SET
[target].[DWIsDeleted] = @BooleanTrue
' END + ';'

--SCD 2
SET @SCD2Script =
'

-- ==================================================
-- SCD2
-- ==================================================

INSERT INTO [' + @DatabaseNameDW + '].[dim].[' + @Table +']
(' + @ColumnNameStage + 
',[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeleted]
)
SELECT 
' + @ColumnNameStage + 
',[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeleted]
FROM
(
MERGE [' + @DatabaseNameDW + '].[dim].[' + @Table +'] as [target]
USING
(
SELECT 
' + @ColumnNameSource + 'FROM  [' + @DatabaseNameStage + '].[' + @StageSchema + '].[' + @Table + ']
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
( ' + @MatchSCD2 + ' )

THEN UPDATE
SET  	[DWIsCurrent] = @BooleanFalse,
		[DWValidToDate] = @DateToDateTime
	
OUTPUT $Action as [MERGE_ACTION_942b9586-8926-4710-a7b0-9eb75b98f9b0],
' + @Output + ',@BooleanTrue AS [DWIsCurrent], 
@CurrentDateTime AS [DWValidFromDate],
@MaxDateTime AS [DWValidToDate],
@CurrentDateTime AS [DWCreatedDate],
@CurrentDateTime AS [DWModifiedDate],
@BooleanFalse AS [DWIsDeleted]

)MERGE_OUTPUT
WHERE MERGE_OUTPUT.[MERGE_ACTION_942b9586-8926-4710-a7b0-9eb75b98f9b0] = ''UPDATE''
	AND ' + @MergeOutput + '
;
'

SET @SCDFullScript = CONCAT(@ParametersScript,CASE WHEN @NumberOfColumnsSCD1 IS NULL THEN NULL ELSE @SCD1Script END,CASE WHEN @NumberOfColumnsSCD2 IS NULL THEN NULL ELSE @SCD2Script END)

/**********************************************************************************************************************************************************************
9. Execute dynamic SQL script variables
**********************************************************************************************************************************************************************/

IF @PrintSQL = 0

	BEGIN

		EXEC(@InsertUnknownScript)
		EXEC(@SCDFullScript)

	END

ELSE

	BEGIN
PRINT(@InsertUnknownScript) + @CRLF + @CRLF
		PRINT(@ParametersScript) + @CRLF + @CRLF
		PRINT(CASE WHEN @NumberOfColumnsSCD1 IS NULL THEN NULL ELSE LEFT(@SCD1Script,4000) END) + @CRLF + @CRLF
		PRINT(CASE WHEN @NumberOfColumnsSCD1 IS NULL THEN NULL ELSE SUBSTRING(@SCD1Script,4001,8000) END) + @CRLF + @CRLF
		PRINT(CASE WHEN @NumberOfColumnsSCD1 IS NULL THEN NULL ELSE SUBSTRING(@SCD1Script,8001,12000)  END) + @CRLF + @CRLF
		PRINT(CASE WHEN @NumberOfColumnsSCD1 IS NULL THEN NULL ELSE SUBSTRING(@SCD1Script,12001,16000) END) + @CRLF + @CRLF
		PRINT(CASE WHEN @NumberOfColumnsSCD2 IS NULL THEN NULL ELSE LEFT(@SCD2Script,4000) END) + @CRLF + @CRLF
		PRINT(CASE WHEN @NumberOfColumnsSCD2 IS NULL THEN NULL ELSE SUBSTRING(@SCD2Script,4001,8000)  END) + @CRLF + @CRLF
		PRINT(CASE WHEN @NumberOfColumnsSCD2 IS NULL THEN NULL ELSE SUBSTRING(@SCD2Script,8001,12000)  END) + @CRLF + @CRLF
		PRINT(CASE WHEN @NumberOfColumnsSCD2 IS NULL THEN NULL ELSE SUBSTRING(@SCD2Script,12001,16000) END)
	END

SET NOCOUNT OFF
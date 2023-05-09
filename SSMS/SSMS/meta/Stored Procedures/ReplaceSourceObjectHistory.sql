CREATE PROCEDURE [meta].[ReplaceSourceObjectHistory] 

 @ExtractTable  NVARCHAR(200),--Input is the extract table with schema
 @PrintSQL BIT

AS

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/

DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10) 
DECLARE @TableSchema NVARCHAR(100) = LEFT(@ExtractTable,CHARINDEX('.',@ExtractTable,0)-1)
DECLARE @Table NVARCHAR(100) = REPLACE(REPLACE(REPLACE(@ExtractTable,CONCAT(@TableSchema,'.'),''),'[',''),']','')
DECLARE @DatabaseNameExtract NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameExtract')
DECLARE @DatabaseNameMeta NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameMeta')
DECLARE @DatabaseNameHistory NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameHistory')
DECLARE @IsCloudFlag NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'IsCloudFlag')
DECLARE @SeparateHistoryFlag NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'SeparateHistoryLayerFlag')
DECLARE @HistoryTable NVARCHAR(100) = IIF(@SeparateHistoryFlag = 1 AND @IsCloudFlag = 1,@Table,@Table + '_History')
DECLARE @HistorySchema NVARCHAR(50) = IIF(@SeparateHistoryFlag = 1 AND @IsCloudFlag = 1,@TableSchema + '_history',@TableSchema)
DECLARE @DatabaseCollation NVARCHAR(100) = (SELECT CONVERT (varchar, DATABASEPROPERTYEX('' + @DatabaseNameMeta + '','collation')))

/**********************************************************************************************************************************************************************
1. Create and insert data into table variables
**********************************************************************************************************************************************************************/

DECLARE @InformationSchema TABLE (DatabaseName NVARCHAR(128), TableName NVARCHAR(128), ColumnName NVARCHAR(128), OrdinalPosition INT, PrimaryKey INT)
DECLARE @ColumnDefaults TABLE (DataType NVARCHAR(50),DefaultValue NVARCHAR(250))

/*Generates the combined information schema*/
INSERT @InformationSchema EXEC('SELECT ''Extract'' AS DATABASE_NAME
										,COLUMNS.TABLE_NAME
										,COLUMNS.COLUMN_NAME
										,COLUMNS.ORDINAL_POSITION
										,CASE WHEN KEY_COLUMN_USAGE.COLUMN_NAME IS NULL THEN 0 
											  ELSE 1 
									     END AS PRIMARY_KEY
								FROM 
									[' + @DatabaseNameExtract + '].INFORMATION_SCHEMA.COLUMNS
								LEFT JOIN 
									[' + @DatabaseNameExtract + '].INFORMATION_SCHEMA.KEY_COLUMN_USAGE
										ON COLUMNS.TABLE_NAME = KEY_COLUMN_USAGE.TABLE_NAME 
										AND COLUMNS.COLUMN_NAME = KEY_COLUMN_USAGE.COLUMN_NAME
										AND COLUMNS.TABLE_SCHEMA = KEY_COLUMN_USAGE.TABLE_SCHEMA
								WHERE 
									COLUMNS.TABLE_NAME = ''' + @Table + ''' 
									AND (COLUMNS.COLUMN_NAME NOT LIKE ''DW%'' 
									OR COLUMNS.COLUMN_NAME = ''DWNavisionCompany'')
									AND COLUMNS.TABLE_SCHEMA NOT LIKE ''%View%''
									AND COLUMNS.TABLE_SCHEMA = ''' + @TableSchema + '''
						

								UNION ALL

								SELECT ''History'' AS DATABASE_NAME
										,COLUMNS.TABLE_NAME
										,COLUMNS.COLUMN_NAME
										,COLUMNS.ORDINAL_POSITION
										,CASE WHEN KEY_COLUMN_USAGE.COLUMN_NAME IS NULL THEN 0 
											  ELSE 1 
										 END AS PRIMARY_KEY
								FROM 
									[' + @DatabaseNameExtract + '].INFORMATION_SCHEMA.COLUMNS
								LEFT JOIN 
									[' + @DatabaseNameExtract + '].INFORMATION_SCHEMA.KEY_COLUMN_USAGE
										ON COLUMNS.TABLE_NAME = KEY_COLUMN_USAGE.TABLE_NAME 
										AND COLUMNS.COLUMN_NAME = KEY_COLUMN_USAGE.COLUMN_NAME
										AND COLUMNS.TABLE_SCHEMA = KEY_COLUMN_USAGE.TABLE_SCHEMA
								WHERE 
									COLUMNS.TABLE_NAME = ''' + @Table + ''' + ''_History''
									AND (COLUMNS.COLUMN_NAME NOT LIKE ''DW%'' 
									OR COLUMNS.COLUMN_NAME = ''DWNavisionCompany'')
									AND COLUMNS.TABLE_SCHEMA = ''' + @TableSchema + '''')



/**********************************************************************************************************************************************************************
2. Create Loop counter and support variables
**********************************************************************************************************************************************************************/

DECLARE @ColumnsExtract INT --Number of columns from Extract
DECLARE @ColumnsHistory INT --Number of columns from History
DECLARE @Counter INT --Just a counter
DECLARE @ColumnsID INT --Number of key columns



SELECT 
	@ColumnsExtract = (SELECT MAX(OrdinalPosition) FROM @InformationSchema WHERE DatabaseName = 'Extract'),
	@Counter = 1,
	@ColumnsID = (SELECT MAX(OrdinalPosition) FROM @InformationSchema WHERE PrimaryKey = 1 AND DatabaseName = 'Extract'),
	@ColumnsHistory = (SELECT MAX(OrdinalPosition) FROM @InformationSchema WHERE DatabaseName = 'History')


/**********************************************************************************************************************************************************************
4. Create columns from extract and output column part
**********************************************************************************************************************************************************************/

DECLARE @PlaceholderColumnNameExtract NVARCHAR(MAX) --Placeholder for the columns from Extract
DECLARE @ColumnNameExtract NVARCHAR(MAX) --Holds the value of @ColumnNameExtract for each loop

WHILE @Counter <= @ColumnsExtract

BEGIN 

	SELECT	@PlaceholderColumnNameExtract = '[' + ColumnName + ']' + CASE 
																		WHEN @Counter != @ColumnsExtract 
																			THEN ',' 
																		ELSE '' 
																	END + @CRLF     
	FROM 
		@InformationSchema
	WHERE 
			DatabaseName = 'Extract' 
		AND TableName = @Table 
		AND OrdinalPosition = @Counter

	SET @ColumnNameExtract = CONCAT(@ColumnNameExtract,@PlaceholderColumnNameExtract)

	SET @PlaceholderColumnNameExtract = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1


/**********************************************************************************************************************************************************************
7. Fill out the dynamic SQL script variables
**********************************************************************************************************************************************************************/

DECLARE @Parameters NVARCHAR(MAX) --Holds the parameter part of the Merge Join Script
DECLARE @ReplacementSQL NVARCHAR(MAX) --Holds the INSERT INTO script

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
	@DateToDateTime = dateadd(ms,-3,  getdate())
'

SET @ReplacementSQL = @Parameters + @CRLF + @CRLF + 'INSERT INTO  [' + @DatabaseNameHistory + '].[' + @HistorySchema + '].[' + @HistoryTable +'] WITH (TABLOCK)' + @CRLF +
'( ' + + @ColumnNameExtract + 
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
',@BooleanTrue
,@MinDateTime
,@MaxDateTime
,@CurrentDateTime
,@CurrentDateTime
,@BooleanFalse
,@MinDateTime

FROM [' + @DatabaseNameExtract + '].[' + @TableSchema + '].[' + @Table + '] '

/**********************************************************************************************************************************************************************
9. Execute dynamic SQL script variables
**********************************************************************************************************************************************************************/

IF @PrintSQL = 0

	BEGIN
		
		EXEC(@ReplacementSQL)
		
	END

ELSE

	BEGIN		
		
		PRINT(LEFT(@ReplacementSQL,4000)) + @CRLF + @CRLF
		PRINT(SUBSTRING(@ReplacementSQL,4001,8000)) + @CRLF + @CRLF
		PRINT(SUBSTRING(@ReplacementSQL,8001,12000)) + @CRLF + @CRLF
		PRINT(SUBSTRING(@ReplacementSQL,12001,16000)) + @CRLF + @CRLF
		
	END

SET NOCOUNT OFF
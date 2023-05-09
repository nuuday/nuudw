CREATE PROCEDURE [meta].[LoadSourceObjectHistory] 

	@ExtractTable  NVARCHAR(200)--Input is the extract table with schema
,	@LoadIsIncremental BIT
,	@SCD2Columns NVARCHAR(MAX) 
,	@PrintSQL BIT 

AS


SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/

SET @ExtractTable = REPLACE(REPLACE(@ExtractTable, '[',''), ']','');

DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10)
DECLARE @TableSchema NVARCHAR(100) = SUBSTRING(@ExtractTable, 0,CHARINDEX('.', @ExtractTable));
DECLARE @Table NVARCHAR(100) = REPLACE(RIGHT(@ExtractTable, LEN(@ExtractTable) - LEN(@TableSchema)), '.', '');
DECLARE @DatabaseNameExtract NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameExtract')
DECLARE @DatabaseNameMeta NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameMeta')
DECLARE @DatabaseNameHistory NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameHistory')
DECLARE @IsCloudFlag NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'IsCloudFlag')
DECLARE @SeparateHistoryFlag NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'SeparateHistoryLayerFlag')
DECLARE @SCD2ColumnsCleansed NVARCHAR(MAX) = IIF(RIGHT(@SCD2Columns,1) = ',',LEFT(@SCD2Columns,LEN(@SCD2Columns)-1),@SCD2Columns)
DECLARE @HistoryTable NVARCHAR(100) = IIF(@SeparateHistoryFlag = 1 AND @IsCloudFlag = 1,@Table,@Table + '_History')
DECLARE @HistorySchema NVARCHAR(50) = IIF(@SeparateHistoryFlag = 1 AND @IsCloudFlag = 1,@TableSchema + '_history',@TableSchema)
DECLARE @DatabaseCollation NVARCHAR(100) = (SELECT CONVERT (varchar, DATABASEPROPERTYEX('' + @DatabaseNameMeta + '','collation')))
DECLARE @TargetTableHasHistoricRows TABLE (HasHistoricRowsFlag BIT)
INSERT INTO @TargetTableHasHistoricRows EXEC('SELECT TOP 1 IIF(DWIsCurrent = 0,1,0) FROM [' + @HistorySchema + '].[' + @HistoryTable + '] WHERE DWIsCurrent = 0')
DECLARE @HasHistoricRowsFlag BIT = ISNULL(IIF(@SCD2Columns = '',(SELECT HasHistoricRowsFlag FROM @TargetTableHasHistoricRows),1),0)
DECLARE @RowExtractedTable TABLE (NumberOfExtractedRows INT)
INSERT INTO @RowExtractedTable EXEC('SELECT COUNT(*) FROM [' + @TableSchema+ '].[' + @Table + ']')
DECLARE @NumberOfExtractedRows INT = (SELECT NumberOfExtractedRows FROM @RowExtractedTable)

/**********************************************************************************************************************************************************************
1. Create and insert data into table variables
**********************************************************************************************************************************************************************/

DECLARE @InformationSchema TABLE (DatabaseName NVARCHAR(128), TableName NVARCHAR(128), ColumnName NVARCHAR(128), OrdinalPosition INT, PrimaryKey INT)
DECLARE @SCD2ColumnTable TABLE (SCD2Columns NVARCHAR(500))
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


/*Generates a table with the SCD2 columns*/
INSERT @SCD2ColumnTable EXEC('WITH AllColumns AS

						  (
						  SELECT COLUMN_NAME
						  FROM [' + @DatabaseNameExtract + '].INFORMATION_SCHEMA.COLUMNS
						  WHERE
							TABLE_SCHEMA = ''' + @TableSchema + '''
							AND TABLE_NAME = ''' + @Table + '''
							AND COLUMN_NAME NOT LIKE ''DW%''

						  )
						  
						  
						  
						  SELECT DISTINCT IIF(Item = ''*'', COLUMN_NAME COLLATE ' + @DatabaseCollation + ', Item) 
						  FROM [meta].[SplitString](''' + @SCD2ColumnsCleansed + ''','','')
						  LEFT JOIN AllColumns ON Item = ''*''
						  WHERE Item <> '''''
						  )
		
					

/**********************************************************************************************************************************************************************
2. Create Loop counter and support variables
**********************************************************************************************************************************************************************/

DECLARE @ColumnsExtract INT --Number of columns from Extract
DECLARE @ColumnsHistory INT --Number of columns from History
DECLARE @ColumnsSCD1 INT --Number of SCD1 columns
DECLARE @ColumnsSCD2 INT --Number of SCD2 columns
DECLARE @Counter INT --Just a counter
DECLARE @ColumnsID INT --Number of key columns
DECLARE @NonKeyColumns INT



SELECT 
	@ColumnsExtract = (SELECT MAX(OrdinalPosition) FROM @InformationSchema WHERE DatabaseName = 'Extract'),
	@Counter = 1,
	@ColumnsID = (SELECT MAX(OrdinalPosition) FROM @InformationSchema WHERE PrimaryKey = 1 AND DatabaseName = 'Extract'),
	@ColumnsHistory = (SELECT MAX(OrdinalPosition) FROM @InformationSchema WHERE DatabaseName = 'History'),
	@ColumnsSCD1 =(SELECT MAX(OrdinalPosition) FROM @InformationSchema C LEFT JOIN @SCD2ColumnTable SCD ON SCD.SCD2Columns = C.ColumnName WHERE DatabaseName = 'Extract' AND SCD.SCD2Columns IS NULL AND PrimaryKey = 0),
	@ColumnsSCD2 =(SELECT MAX(OrdinalPosition) FROM @InformationSchema C LEFT JOIN @SCD2ColumnTable SCD ON SCD.SCD2Columns = C.ColumnName WHERE DatabaseName = 'Extract' AND (PrimaryKey = 1 OR SCD.SCD2Columns IS NOT NULL)),
	@NonKeyColumns = (SELECT COUNT(ColumnName) FROM @InformationSchema WHERE DatabaseName = 'Extract' AND PrimaryKey = 0)


/**********************************************************************************************************************************************************************
3. Create Merge Keys part and Merge Ouput part
**********************************************************************************************************************************************************************/

DECLARE @PlaceholderKeys NVARCHAR(MAX) --Placeholder used in the loop generating the business keys used in the Merge Join script
DECLARE @Keys NVARCHAR(MAX) --Holds the value of @Keys for each loop
DECLARE @KeyFields NVARCHAR(MAX) --Holds the value of @Keys for each loop
DECLARE @PlaceholderKeyFields NVARCHAR(MAX) --Holds the value of @Keys for each loop

WHILE @Counter <= @ColumnsID

BEGIN

	SELECT	
		@PlaceholderKeys = '[SOURCE].' + QUOTENAME(ColumnName) + ' = [TARGET].' + QUOTENAME(ColumnName) + CASE 
																										WHEN @Counter != @ColumnsID 
																											THEN ' AND ' 
																										ELSE '' 
																								  END,
		@PlaceholderKeyFields = QUOTENAME(ColumnName) + CASE WHEN @Counter != @ColumnsID THEN ', ' ELSE '' END
	FROM 
		@InformationSchema
	WHERE 
			OrdinalPosition = @Counter 
		AND PrimaryKey = 1 
		AND DatabaseName = 'Extract'

	SET @Keys = CONCAT(@Keys,@PlaceholderKeys)
	SET @KeyFields = CONCAT(@KeyFields,@PlaceholderKeyFields)

	SET @PlaceholderKeys = ''
	SET @PlaceholderKeyFields = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
4. Create columns from extract and output column part
**********************************************************************************************************************************************************************/

DECLARE @PlaceholderColumnNameTarget NVARCHAR(MAX) --Placeholder for the columns from Extract
DECLARE @ColumnNameTarget NVARCHAR(MAX) --Holds the value of @ColumnNameExtract for each loop
DECLARE @PlaceholderColumnNames NVARCHAR(MAX) --Placeholder for the columns from Extract
DECLARE @ColumnNames NVARCHAR(MAX) --Holds the value of @ColumnNameExtract for each loop
DECLARE @PlaceholderColumnNameSource NVARCHAR(MAX) --Placeholder for the output part of the script
DECLARE @ColumnNameSource NVARCHAR(MAX) --Holds the value of @ColumnNameDim for each loop
DECLARE @PlaceholderColumnNameMerge NVARCHAR(MAX) --Placeholder for the output part of the script
DECLARE @ColumnNameMerge NVARCHAR(MAX) --Holds the value of @ColumnNameDim for each loop

WHILE @Counter <= @ColumnsExtract

BEGIN 

	SELECT	@PlaceholderColumnNameTarget = '[TARGET].' + QUOTENAME(ColumnName) + ' AS ' + QUOTENAME(ColumnName) + '' + CASE 
																										WHEN @Counter != @ColumnsExtract 
																											THEN ', ' 
																										ELSE '' 
																									END + @CRLF,
			@PlaceholderColumnNameSource = '[SOURCE].' + QUOTENAME(ColumnName) + ' AS ' + QUOTENAME(ColumnName) + '' + CASE 
																									    WHEN @Counter != @ColumnsExtract 
																											THEN ', ' 
																										ELSE '' 
																									END + @CRLF,
			@PlaceholderColumnNameMerge = '[MERGE].' + QUOTENAME(ColumnName) + '' + CASE 
																				WHEN @Counter != @ColumnsExtract 
																					THEN ', ' 
																				ELSE '' 
																			END + @CRLF,
			@PlaceholderColumnNames = '' + QUOTENAME(ColumnName) + '' +  CASE 
																	WHEN @Counter != @ColumnsExtract 
																		THEN ', ' 
																	ELSE '' 
																END + @CRLF																					
	FROM 
		@InformationSchema
	WHERE 
			DatabaseName = 'Extract' 
		AND TableName = @Table 
		AND OrdinalPosition = @Counter

	SET @ColumnNameTarget = CONCAT(@ColumnNameTarget,@PlaceholderColumnNameTarget)

	SET @PlaceholderColumnNameTarget = ''

	SET @ColumnNameSource = CONCAT(@ColumnNameSource,@PlaceholderColumnNameSource)

	SET @PlaceholderColumnNameSource = ''

	SET @ColumnNameMerge = CONCAT(@ColumnNameMerge,@PlaceholderColumnNameMerge)

	SET @PlaceholderColumnNameMerge = ''

	SET @ColumnNames = CONCAT(@ColumnNames,@PlaceholderColumnNames)

	SET @PlaceholderColumnNames = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
5.Create update part and match part for SCD1 columns
**********************************************************************************************************************************************************************/

DECLARE @PlaceholderColumnNamesSourceSCD1 NVARCHAR(MAX) --Placeholder for the update SCD1 part of the script
DECLARE @ColumnNamesSourceSCD1 NVARCHAR(MAX) --Holds the value of @ColumnNameDim for each loop
DECLARE @PlaceholderColumnNamesTargetSCD1 NVARCHAR(MAX) --Placeholder for the update SCD1 part of the script
DECLARE @ColumnNamesTargetSCD1 NVARCHAR(MAX) --Holds the value of @ColumnNameDim for each loop
DECLARE @PlaceholderColumnNamesSCD1WithHistorySCD1 NVARCHAR(MAX) 
DECLARE @ColumnNamesSCD1WithHistorySCD1 NVARCHAR(MAX) 
DECLARE @PlaceholderColumnNamesSCD1WithHistorySCD2 NVARCHAR(MAX) 
DECLARE @ColumnNamesSCD1WithHistorySCD2 NVARCHAR(MAX) 

WHILE @Counter <= @ColumnsExtract

BEGIN 

	SELECT	@PlaceholderColumnNamesSourceSCD1 = IIF(SCD.SCD2Columns IS NULL,'[SOURCE].' + QUOTENAME(ColumnName) + '' +  CASE 
																								WHEN @Counter != @ColumnsExtract 
																									THEN ', ' 
																								ELSE '' 
																							END + @CRLF, ''),
			@PlaceholderColumnNamesTargetSCD1 = IIF(SCD.SCD2Columns IS NULL,'[TARGET].' + QUOTENAME(ColumnName) + '' +  CASE 
																								WHEN @Counter != @ColumnsExtract 
																									THEN ', ' 
																								ELSE '' 
																							END + @CRLF, ''),
			@PlaceholderColumnNamesSCD1WithHistorySCD1 = IIF(SCD.SCD2Columns IS NULL, '[SOURCE].', '[TARGET].') + QUOTENAME(ColumnName) + '' +	CASE 
																																					WHEN @Counter != @ColumnsExtract 
																																						THEN ', ' 
																																					ELSE '' 
																																				END + @CRLF,
			@PlaceholderColumnNamesSCD1WithHistorySCD2 = IIF(SCD.SCD2Columns IS NULL, '[TARGET].', '[SOURCE].') + QUOTENAME(ColumnName) + '' +	CASE 
																																					WHEN @Counter != @ColumnsExtract 
																																						THEN ', ' 
																																					ELSE '' 
																																				END + @CRLF
	FROM 
		@InformationSchema AS InformationSchema
	LEFT JOIN 
		@SCD2ColumnTable AS SCD 
			ON SCD.SCD2Columns = InformationSchema.ColumnName
	WHERE 
			DatabaseName = 'Extract' 
		AND OrdinalPosition = @Counter 

	SET @ColumnNamesSourceSCD1 = CONCAT(@ColumnNamesSourceSCD1,@PlaceholderColumnNamesSourceSCD1)

	SET @PlaceholderColumnNamesSourceSCD1 = ''

	SET @ColumnNamesTargetSCD1 = CONCAT(@ColumnNamesTargetSCD1,@PlaceholderColumnNamesTargetSCD1)

	SET @PlaceholderColumnNamesTargetSCD1 = ''

	SET @ColumnNamesSCD1WithHistorySCD1 = CONCAT(@ColumnNamesSCD1WithHistorySCD1,@PlaceholderColumnNamesSCD1WithHistorySCD1)

	SET @PlaceholderColumnNamesSCD1WithHistorySCD1 = ''

	SET @ColumnNamesSCD1WithHistorySCD2 = CONCAT(@ColumnNamesSCD1WithHistorySCD2,@PlaceholderColumnNamesSCD1WithHistorySCD2)

	SET @PlaceholderColumnNamesSCD1WithHistorySCD2 = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1



/**********************************************************************************************************************************************************************
6.Create update part and match part for SCD2 columns
**********************************************************************************************************************************************************************/

DECLARE @PlaceholderColumnNamesSourceSCD2 NVARCHAR(MAX) --Placeholder for the update SCD1 part of the script
DECLARE @ColumnNamesSourceSCD2 NVARCHAR(MAX) --Holds the value of @ColumnNameDim for each loop
DECLARE @PlaceholderColumnNamesTargetSCD2 NVARCHAR(MAX) --Placeholder for the update SCD1 part of the script
DECLARE @ColumnNamesTargetSCD2 NVARCHAR(MAX) --Holds the value of @ColumnNameDim for each loop

WHILE @Counter <= @ColumnsSCD2

BEGIN 

	SELECT  @PlaceholderColumnNamesSourceSCD2 = '[SOURCE].' + QUOTENAME(ColumnName) +  CASE 
																	WHEN @Counter != @ColumnsSCD2 
																		THEN ', ' 
																	ELSE '' 
																END,	
			@PlaceholderColumnNamesTargetSCD2 = '[TARGET].' + QUOTENAME(ColumnName) +  CASE 
																	WHEN @Counter != @ColumnsSCD2 
																		THEN ', ' 
																	ELSE '' 
																END		
       
	FROM 
		@InformationSchema AS InformationSchema
	LEFT JOIN 
		@SCD2ColumnTable AS SCD 
			ON SCD.SCD2Columns = InformationSchema.ColumnName
	WHERE 
			DatabaseName = 'Extract' 
		AND OrdinalPosition = @Counter 
		AND (PrimaryKey = 1 OR SCD.SCD2Columns IS NOT NULL)

	SET @ColumnNamesSourceSCD2 = CONCAT(@ColumnNamesSourceSCD2,@PlaceholderColumnNamesSourceSCD2);
	SET @PlaceholderColumnNamesSourceSCD2 = '';
	SET @ColumnNamesTargetSCD2 = CONCAT(@ColumnNamesTargetSCD2,@PlaceholderColumnNamesTargetSCD2);
	SET @PlaceholderColumnNamesTargetSCD2 = '';
	SET @Counter = @Counter + 1;

END

SET @Counter = 1;

/**********************************************************************************************************************************************************************
6. Fill out the dynamic SQL script variables
**********************************************************************************************************************************************************************/

DECLARE @Parameters NVARCHAR(MAX) --Holds the parameter part of the Merge Join Script
DECLARE @Deletes NVARCHAR(MAX) --Holds the delete part of the Script
DECLARE @UnDeletes NVARCHAR(MAX) --Holds the delete part of the Script
DECLARE @Inserts NVARCHAR(MAX) --Holds the insert part of the Script
DECLARE @UpdatesSCD1 NVARCHAR(MAX) --Holds the update part of the Script
DECLARE @UpdatesSCD1WithHistory NVARCHAR(MAX) --Holds the update part of the Script
DECLARE @UpdatesSCD2 NVARCHAR(MAX) --Holds the update part of the Script
DECLARE @FullScript NVARCHAR(MAX) --Combining 
DECLARE @DeleteSQL NVARCHAR(MAX)
DECLARE @ReplaceSQL NVARCHAR(MAX)
DECLARE @SourceTableHasDWOperation BIT = 0

/* Do we have an IUD audit column from source e.g CDC or CT TRUE/FALSE */
SET @SourceTableHasDWOperation = (SELECT IIF( COL_LENGTH('' + @DatabaseNameExtract + '.' + @TableSchema + '.' + @Table + '', 'DWOperation') > 0, 1, 0) );

SET @Parameters =
'DECLARE @CurrentDateTime DATETIME;
DECLARE @MinDateTime DATETIME;
DECLARE @MaxDateTime DATETIME;
DECLARE @BooleanTrue BIT;
DECLARE @BooleanFalse BIT;
DECLARE @DateToDateTime DATETIME


SELECT
	@CurrentDateTime = CAST(GETDATE() AS DATETIME)
,	@MinDateTime	 = CAST(''1900-01-01'' AS DATETIME)
,	@MaxDateTime	 = CAST(''9999-12-31'' AS DATETIME)
,	@BooleanTrue	 = CAST(1 AS BIT)
,	@BooleanFalse	 = CAST(0 AS BIT)
,	@DateToDateTime  = DATEADD(MS,-3,  GETDATE())


-- ==================================================
-- Create #temp table #ChangedRecords 
-- to hold deleted and updated records
-- ==================================================

DROP TABLE IF EXISTS #ChangedRecords;

-- ==================================================
-- Create #temp table #ChangedRecords 
-- based on [@HistorySchema].[@HistoryTable] definition
-- ==================================================

SELECT 
' + @ColumnNameTarget + '
,[TARGET].[DWIsCurrent]
,[TARGET].[DWValidFromDate]
,[TARGET].[DWValidToDate]
,[TARGET].[DWCreatedDate]
,[TARGET].[DWModifiedDate]
,[TARGET].[DWIsDeletedInSource]
,[TARGET].[DWDeletedInSourceDate]
,[ETLOperation] = CAST(NULL AS NVARCHAR(30)) /* Internal Change Audit column used in data flow task decission - NOT the same as CDC or CT DWOperation */
INTO 
	#ChangedRecords
FROM 
	' + QUOTENAME(@DatabaseNameHistory) + '.' + QUOTENAME(@HistorySchema) + '.' + QUOTENAME(@HistoryTable) + '  AS [TARGET] 
WHERE 1 = 0 ;
'


SET @Deletes = IIF(@LoadIsIncremental = 1 AND @SourceTableHasDWOperation = 0, '', '

-- ==================================================
-- Prepare Deleted Records store TARGET records 
-- in #temp table #ChangedRecords change audit columns
-- ==================================================

INSERT INTO #ChangedRecords WITH (TABLOCKX)
(' + @ColumnNames + '
,[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeletedInSource]
,[DWDeletedInSourceDate]
,[ETLOperation])

SELECT 
' + @ColumnNameTarget + '
,[DWIsCurrent]				=	[TARGET].[DWIsCurrent]
,[DWValidFromDate]			=	[TARGET].[DWValidFromDate]
,[DWValidToDate]			=	[TARGET].[DWValidToDate]
,[DWCreatedDate]			=	[TARGET].[DWCreatedDate]
,[DWModifiedDate]			=	@CurrentDateTime
,[DWIsDeletedInSource]		=	@BooleanTrue 
,[DWDeletedInSourceDate]	=	@CurrentDateTime
,[ETLOperation]				=	''Deleted''
FROM 
	' + QUOTENAME(@DatabaseNameHistory) + '.' + QUOTENAME(@HistorySchema) + '.' + QUOTENAME(@HistoryTable) + ' AS [TARGET]
' +
CASE 
	WHEN (@LoadIsIncremental = 1) AND (@SourceTableHasDWOperation = 1) 
		THEN
	'INNER JOIN 
	' + QUOTENAME(@DatabaseNameExtract) + '.' + QUOTENAME(@TableSchema) + '.' + QUOTENAME(@Table) + ' AS [SOURCE]
		ON (' + @Keys + ') AND ([SOURCE].[DWOperation] IN (''D'')) '
	ELSE 
	'WHERE
	NOT EXISTS (SELECT 1 
				FROM ' + QUOTENAME(@DatabaseNameExtract) + '.' + QUOTENAME(@TableSchema) + '.' + QUOTENAME(@Table) + ' AS [SOURCE] 
					WHERE 
						(' + @Keys + ')
				) '
END + 
'AND ([TARGET].[DWIsDeletedInSource] = 0) ;
'
) 



SET @UpdatesSCD1 =	
' 
-- ==================================================
-- Updated Records SCD1 without SCD2 columns
-- ==================================================

INSERT INTO #ChangedRecords WITH (TABLOCKX)
(' + @ColumnNames + '
,[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeletedInSource]
,[DWDeletedInSourceDate]
,[ETLOperation]
)

SELECT 
' + @ColumnNameSource + '
,[DWIsCurrent]				=	[TARGET].[DWIsCurrent]
,[DWValidFromDate]			=	[TARGET].[DWValidFromDate]
,[DWValidToDate]			=	[TARGET].[DWValidToDate]
,[DWCreatedDate]			=	[TARGET].[DWCreatedDate]
,[DWModifiedDate]			=	@CurrentDateTime
,[DWIsDeletedInSource]		=	@BooleanFalse 
,[DWDeletedInSourceDate]	=	@MinDateTime
,[ETLOperation]				=	''SCD1 - Update''
FROM 
	' + QUOTENAME(@DatabaseNameExtract) + '.' + QUOTENAME(@TableSchema) + '.' + QUOTENAME(@Table) + ' AS [SOURCE]
INNER JOIN
	' + QUOTENAME(@DatabaseNameHistory) + '.' + QUOTENAME(@HistorySchema) + '.' + QUOTENAME(@HistoryTable) + ' AS [TARGET] 
		ON (' + @Keys + ') AND ([TARGET].[DWIsCurrent] = 1)' + IIF(@SourceTableHasDWOperation = 1, ' AND ([SOURCE].[DWOperation] IN (''I'', ''U'')) ', '') + '
WHERE
	EXISTS
( SELECT 
' + @ColumnNameSource + ' 
  EXCEPT
  SELECT 
' + @ColumnNameTarget + ' )
;'

SET @UpdatesSCD1WithHistory =	
'
-- ==================================================
-- Updated Records SCD1 with SCD2 columns
-- ==================================================

INSERT INTO #ChangedRecords WITH (TABLOCKX)
(' + @ColumnNames + '
,[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeletedInSource]
,[DWDeletedInSourceDate]
,[ETLOperation])

SELECT 
' + @ColumnNamesSCD1WithHistorySCD1 + '
,[DWIsCurrent]				=	[TARGET].[DWIsCurrent]
,[DWValidFromDate]			=	[TARGET].[DWValidFromDate]
,[DWValidToDate]			=	[TARGET].[DWValidToDate]
,[DWCreatedDate]			=	[TARGET].[DWCreatedDate]
,[DWModifiedDate]			=	@CurrentDateTime
,[DWIsDeletedInSource]		=	@BooleanFalse 
,[DWDeletedInSourceDate]	=	@MinDateTime
,[ETLOperation]				=	IIF([TARGET].[DWIsCurrent] = 1,''SCD1 Update - Current'',''SCD1 Update - History'')
FROM 
	' + QUOTENAME(@DatabaseNameExtract) + '.' + QUOTENAME(@TableSchema) + '.' + QUOTENAME(@Table) + ' AS [SOURCE]
INNER JOIN
	' + QUOTENAME(@DatabaseNameHistory) + '.' + QUOTENAME(@HistorySchema) + '.' + QUOTENAME(@HistoryTable) + ' AS [TARGET] 
		ON (' + @Keys + ')' + IIF(@SourceTableHasDWOperation = 1, ' AND ([SOURCE].[DWOperation] IN (''I'', ''U'')) ', '') + '
WHERE
	EXISTS
( SELECT 
' + @ColumnNamesSourceSCD1 + ' 
  EXCEPT
  SELECT 
' + @ColumnNamesTargetSCD1 + ' )
;'

SET @UpdatesSCD2 = 
'
-- ==================================================
-- Create #temp table #ChangedSCD1WithHistoryRecords 
-- Records which is updated though a SCD type 1 
-- but also triggered by a SCD type 2 update 
-- ==================================================

DROP TABLE IF EXISTS #ChangedSCD1WithHistoryRecords;

-- ==================================================
-- Updated Records SCD2
-- Close existing records
-- ==================================================

/* Handle Updates from Source - Close existing records */ 
SELECT
' + @ColumnNamesSCD1WithHistorySCD1 + '
,[DWIsCurrent]				= @BooleanFalse
,[DWValidFromDate]			= [TARGET].[DWValidFromDate]
,[DWValidToDate]			= @DateToDateTime
,[DWCreatedDate]			= [TARGET].[DWCreatedDate]
,[DWModifiedDate]			= @CurrentDateTime
,[DWIsDeletedInSource]		= [TARGET].[DWIsDeletedInSource]	
,[DWDeletedInSourceDate]	= [TARGET].[DWDeletedInSourceDate]
,[ETLOperation]				= ''SCD2 Update - Closing'' -- BeforeUpdate
INTO 
	#ChangedSCD1WithHistoryRecords
FROM		
  ' + QUOTENAME(@DatabaseNameHistory) + '.' + QUOTENAME(@HistorySchema) + '.' + QUOTENAME(@HistoryTable) + ' AS [TARGET]
INNER JOIN
	' + QUOTENAME(@DatabaseNameExtract) + '.' + QUOTENAME(@TableSchema) + '.' + QUOTENAME(@Table) + ' AS [SOURCE]
		ON (' + @Keys + ') AND ([TARGET].[DWIsCurrent] = 1)' + IIF(@SourceTableHasDWOperation = 1, ' AND ([SOURCE].[DWOperation] IN (''I'', ''U'')) ', '') + '
WHERE
	EXISTS
(SELECT 
' + @ColumnNamesSourceSCD2 + ' 
  
 EXCEPT
 
 SELECT 
' + @ColumnNamesTargetSCD2 + '
) ;

-- ==================================================
-- Updated Records SCD2
-- Delete SCD type 1 records which is triggered by
-- an SCD type 2 update - Insert SCD1 records and
-- SCD type 2 records.
-- ==================================================

/* Delete SCD1 updates which is triggered by and SCD2 update */
DELETE [TARGET] WITH (TABLOCKX) 
FROM 
	#ChangedRecords AS [TARGET]
INNER JOIN
	#ChangedSCD1WithHistoryRecords AS [SOURCE]
		ON (' + @Keys + ') AND (([SOURCE].[ETLOperation] = ''SCD2 Update - Closing'')  ' + IIF(ISNULL(@SCD2Columns,'') LIKE '*%',');','AND ([TARGET].[ETLOperation] = ''SCD1 Update - Current''))') + '
;

/* Insert SCD1 records with SCD2 audit History */
INSERT INTO #ChangedRecords WITH (TABLOCKX) 
(' + @ColumnNames + '
,[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeletedInSource]
,[DWDeletedInSourceDate]
,[ETLOperation])

SELECT
' + @ColumnNames + '
,[DWIsCurrent]			
,[DWValidFromDate]		
,[DWValidToDate]		
,[DWCreatedDate]		
,[DWModifiedDate]		
,[DWIsDeletedInSource]	
,[DWDeletedInSourceDate]
,[ETLOperation]			
FROM  
	#ChangedSCD1WithHistoryRecords AS [SOURCE]
;

-- ==================================================
-- Updated Records SCD2
-- Create new SCD2 records
-- ==================================================

INSERT INTO #ChangedRecords WITH (TABLOCKX) 
(' + @ColumnNames + '
,[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeletedInSource]
,[DWDeletedInSourceDate]
,[ETLOperation])

SELECT
' + @ColumnNamesSCD1WithHistorySCD2 + '
,[DWIsCurrent]				= @BooleanTrue		
,[DWValidFromDate]			= @CurrentDateTime	
,[DWValidToDate]			= @MaxDateTime		
,[DWCreatedDate]			= @CurrentDateTime	
,[DWModifiedDate]			= @CurrentDateTime	
,[DWIsDeletedInSource]		= @BooleanFalse		
,[DWDeletedInSourceDate]	= @MinDateTime
,[ETLOperation]				= ''SCD2 Insert - Opening'' -- AfterUpdate
FROM		
	#ChangedSCD1WithHistoryRecords AS [TARGET]
INNER JOIN
	' + QUOTENAME(@DatabaseNameExtract) + '.' + QUOTENAME(@TableSchema) + '.' + QUOTENAME(@Table) + ' AS [SOURCE]
		ON (' + @Keys + ') AND ([TARGET].[DWIsCurrent] = 0) AND ([TARGET].[ETLOperation] = ''SCD2 Update - Closing'')
;'


SET @UnDeletes ='

-- ==================================================
-- Prepare UnDeleted Records store TARGET records 
-- which has not been changed through other operations
-- ==================================================

DROP TABLE IF EXISTS #Undeletes

SELECT 
' + @ColumnNameTarget + '
,[DWIsCurrent]				=	[TARGET].[DWIsCurrent]
,[DWValidFromDate]			=	[TARGET].[DWValidFromDate]
,[DWValidToDate]			=	[TARGET].[DWValidToDate]
,[DWCreatedDate]			=	[TARGET].[DWCreatedDate]
,[DWModifiedDate]			=	@CurrentDateTime
,[DWIsDeletedInSource]		=	@BooleanFalse
,[DWDeletedInSourceDate]	=	@MinDateTime
,[ETLOperation]				=	''UnDeleted''
INTO 
	#Undeletes
FROM 
	' + QUOTENAME(@DatabaseNameHistory) + '.' + QUOTENAME(@HistorySchema) + '.' + QUOTENAME(@HistoryTable) + ' AS [TARGET]
WHERE
		EXISTS (SELECT 1 
				FROM ' + QUOTENAME(@DatabaseNameExtract) + '.' + QUOTENAME(@TableSchema) + '.' + QUOTENAME(@Table) + ' AS [SOURCE] 
					WHERE 
						(' + @Keys + ')
				) 
 AND ([TARGET].[DWIsDeletedInSource] = 1)
 AND NOT EXISTS (SELECT 1 
				FROM #ChangedRecords AS [SOURCE] 
					WHERE 
						(' + @Keys + ')
				) ;


INSERT INTO #ChangedRecords WITH (TABLOCKX)
(' + @ColumnNames + '
,[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeletedInSource]
,[DWDeletedInSourceDate]
,[ETLOperation])

SELECT 
' + @ColumnNameSource + '
,[DWIsCurrent]				
,[DWValidFromDate]			
,[DWValidToDate]			
,[DWCreatedDate]			
,[DWModifiedDate]			
,[DWIsDeletedInSource]		
,[DWDeletedInSourceDate]	
,[ETLOperation]				
FROM 
	#Undeletes AS [SOURCE]
'


SET @Inserts = 
'
-- ==================================================
-- New Records which does not exists
-- ==================================================	

INSERT INTO #ChangedRecords WITH (TABLOCKX)
(' + @ColumnNames + '
,[DWIsCurrent]
,[DWValidFromDate]
,[DWValidToDate]
,[DWCreatedDate]
,[DWModifiedDate]
,[DWIsDeletedInSource]
,[DWDeletedInSourceDate]
,[ETLOperation])

SELECT 
' + @ColumnNameSource + '
,[DWIsCurrent]				=	@BooleanTrue
,[DWValidFromDate]			=	@MinDateTime
,[DWValidToDate]			=	@MaxDateTime
,[DWCreatedDate]			=	@CurrentDateTime
,[DWModifiedDate]			=	@CurrentDateTime
,[DWIsDeletedInSource]		=	@BooleanFalse
,[DWDeletedInSourceDate]	=	@MinDateTime
,[ETLOperation]				=   ''Insert''
FROM 
	' + QUOTENAME(@DatabaseNameExtract) + '.' + QUOTENAME(@TableSchema) + '.' + QUOTENAME(@Table) + ' AS [SOURCE]
WHERE
	NOT EXISTS
		(SELECT 1 FROM ' + QUOTENAME(@DatabaseNameHistory) + '.' + QUOTENAME(@HistorySchema) + '.' + QUOTENAME(@HistoryTable) + ' AS [TARGET]
		 WHERE
			(' + @Keys + '))' + IIF(@SourceTableHasDWOperation = 1, ' AND ([SOURCE].[DWOperation] IN (''I'', ''U'')) ', '') + '
;


-- ==================================================
-- Before deleting existing records we add a NC Index 
-- to optimize index-scan instead of table scan
-- ==================================================	

CREATE NONCLUSTERED INDEX [NCI_ChangedRecords] ON #ChangedRecords (' + @KeyFields + ', [DWValidFromDate]);

-- ==================================================
-- UnDeleted Records which has been changed through 
-- other operations is undeleted
-- ==================================================	

UPDATE TARGET WITH (TABLOCKX)
SET [DWIsDeletedInSource]	=	@BooleanFalse
   ,[DWDeletedInSourceDate]	=	@MinDateTime
FROM 
	#ChangedRecords AS TARGET
WHERE
	EXISTS (SELECT 1 
				FROM ' + QUOTENAME(@DatabaseNameExtract) + '.' + QUOTENAME(@TableSchema) + '.' + QUOTENAME(@Table) + ' AS [SOURCE] 
					WHERE 
						(' + @Keys + ')
				) 
	AND ([TARGET].[DWIsDeletedInSource] = 1) ;

BEGIN TRY
	BEGIN TRANSACTION

	-- ==================================================
	-- Delete soft-deleted- and updated records
	-- ==================================================	
	
	DELETE [TARGET] WITH (TABLOCKX)
	FROM 
		' + QUOTENAME(@DatabaseNameHistory) + '.' + QUOTENAME(@HistorySchema) + '.' + QUOTENAME(@HistoryTable) + ' AS [TARGET]
	INNER JOIN 
		#ChangedRecords AS [SOURCE]
			ON (' + @Keys + ' AND [SOURCE].[DWValidFromDate] = [TARGET].[DWValidFromDate])
	;
	
	
	-- ==================================================
	-- Insert records
	-- ==================================================
	
	INSERT INTO ' + QUOTENAME(@DatabaseNameHistory) + '.' + QUOTENAME(@HistorySchema) + '.' + QUOTENAME(@HistoryTable) + ' WITH (TABLOCKX)
	(' + @ColumnNames + '
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate])
	
	SELECT 
	' + @ColumnNameSource + '
	,[SOURCE].[DWIsCurrent]
	,[SOURCE].[DWValidFromDate]
	,[SOURCE].[DWValidToDate]
	,[SOURCE].[DWCreatedDate]
	,[SOURCE].[DWModifiedDate]
	,[SOURCE].[DWIsDeletedInSource]
	,[SOURCE].[DWDeletedInSourceDate]
	FROM 
		#ChangedRecords AS [SOURCE]
	;

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
	DECLARE @Message varchar(MAX) = ERROR_MESSAGE(),
        @Severity int = ERROR_SEVERITY(),
        @State smallint = ERROR_STATE() 
   RAISERROR (@Message, @Severity, @State)
END CATCH;
'


SET @FullScript = IIF(@ColumnsSCD1 IS NULL AND ISNULL(@SCD2Columns,'') = '','',CONCAT(@Parameters,@Deletes,CASE WHEN @ColumnsSCD1 IS NULL THEN NULL ELSE IIF(@HasHistoricRowsFlag = 1,@UpdatesSCD1WithHistory,@UpdatesSCD1) END,CASE WHEN ISNULL(@SCD2Columns,'') = '' THEN NULL ELSE @UpdatesSCD2 END,@UnDeletes,@Inserts))

/**********************************************************************************************************************************************************************
8. Execute dynamic SQL script variables
**********************************************************************************************************************************************************************/

IF @PrintSQL = 0 

	BEGIN
		IF @NumberOfExtractedRows = 0 AND @LoadIsIncremental = 0
			BEGIN 
				PRINT('No extracted rows in full load. Merge terminated')
			END
		ELSE
			BEGIN
				EXEC(@FullScript)
			END
	END

ELSE

	BEGIN
		
				PRINT(LEFT(@FullScript,4000)) 
				PRINT(SUBSTRING(@FullScript,4001,8000)) 
				PRINT(SUBSTRING(@FullScript,8001,12000)) 
				PRINT(SUBSTRING(@FullScript,12001,16000)) 
				PRINT(SUBSTRING(@FullScript,16001,20000)) 
				PRINT(SUBSTRING(@FullScript,20001,24000)) 
				PRINT(SUBSTRING(@FullScript,24001,28000)) 
				PRINT(SUBSTRING(@FullScript,28001,32000)) 
				PRINT(SUBSTRING(@FullScript,32001,36000)) 
				PRINT(SUBSTRING(@FullScript,36001,40000)) 
				PRINT(SUBSTRING(@FullScript,40001,44000)) 
				PRINT(SUBSTRING(@FullScript,44001,48000)) 
				PRINT(SUBSTRING(@FullScript,48001,52000)) 
				PRINT(SUBSTRING(@FullScript,52001,56000)) 
				PRINT(SUBSTRING(@FullScript,56001,60000)) 
				PRINT(SUBSTRING(@FullScript,60001,64000)) 
				PRINT(SUBSTRING(@FullScript,64001,68000)) 
				PRINT(SUBSTRING(@FullScript,68001,72000)) 
				PRINT(SUBSTRING(@FullScript,72001,76000)) 
				PRINT(SUBSTRING(@FullScript,76001,80000)) 
				PRINT(SUBSTRING(@FullScript,80001,84000)) 
				PRINT(SUBSTRING(@FullScript,84001,88000)) 
				PRINT(SUBSTRING(@FullScript,88001,92000)) 
				PRINT(SUBSTRING(@FullScript,92001,96000)) 
				PRINT(SUBSTRING(@FullScript,96001,100000)) 
		
	END

SET NOCOUNT OFF
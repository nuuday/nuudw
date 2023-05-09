

/**********************************************************************************************************************************************************************
The purpose of this scripts is to create and execute the update table between stage and dw. 
***********************************************************************************************************************************************************************/


CREATE PROCEDURE [meta].[MaintainDWUpdateTable]

@Table NVARCHAR(100),--Input is the table name without schema
@DestinationSchema NVARCHAR(10),--Input is the destination schema (dim, fact or bridge)
@PrintSQL BIT--Enter 1 if you want to print the dynamic SQL and 0 if you want to execute the dynamic SQL

AS

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/

DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10) 
DECLARE @DatabaseNameStage NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameStage')
DECLARE @DatabaseNameDW NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameDW')
DECLARE @DatabaseNameMeta NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameMeta')
DECLARE @SurrogateKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'SurrogateKeySuffix')
DECLARE @BusinessKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'BusinessKeySuffix')
DECLARE @FactIsIncremental BIT = (SELECT FactAndBridgeIncrementalFlag FROM meta.BusinessMatrix WHERE TableName = @Table AND DestinationSchema = @DestinationSchema)
DECLARE @LoadPattern NVARCHAR(50) = (SELECT LoadPattern FROM meta.BusinessMatrix WHERE TableName = @Table)
DECLARE @IsCloudFlag BIT = IIF((SELECT VariableValue FROM meta.Variables WHERE VariableName = 'IsCloudFlag') = '1',1,0)
DECLARE @StageSchemaTable TABLE (SchemaName NVARCHAR(10)) 
INSERT @StageSchemaTable EXEC('SELECT DISTINCT TABLE_SCHEMA FROM [' + @DatabaseNameStage + '].INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @Table + ''' AND TABLE_SCHEMA IN (''dbo'',''stage'')')
DECLARE @StageSchema NVARCHAR(10) = (SELECT IIF(@IsCloudFlag = 1,'stage',(SELECT SchemaName FROM @StageSchemaTable))) --If on-premise and stageschema has not been changed
DECLARE @DatabaseCollation NVARCHAR(100) = (SELECT CONVERT (varchar, DATABASEPROPERTYEX('' + @DatabaseNameMeta + '','collation')))
DECLARE @CreateTruncateProperty BIT = (SELECT TruncateBeforeDeployFlag FROM meta.BusinessMatrix WHERE TableName = @Table AND DestinationSchema = @DestinationSchema)


/**********************************************************************************************************************************************************************
1. Create and insert data into table variables
***********************************************************************************************************************************************************************/

DECLARE @InformationSchema TABLE (DatabaseName NVARCHAR(128), TableName NVARCHAR(128), ColumnName NVARCHAR(128), OrdinalPosition INT, DataType NVARCHAR(128), CharacterMaximumLenght INT, NumericPrecision INT, NumericScale INT, PrimaryKey INT, DefaultConstraintName NVARCHAR(128))
DECLARE @DWRelations TABLE (TableName NVARCHAR(128), DimensionName NVARCHAR(128), TableColumnName NVARCHAR(128), DimensionColumnMappingName NVARCHAR(128), RolePlayingDimensionName NVARCHAR(128), IsSCD2DimensionFlag NVARCHAR(10), IsSCD2CompositeKeyDimensionFlag NVARCHAR(10), ColumnOrdinalPosition INT, IsNewDimensionFlag NVARCHAR(128), DefaultErrorValue NVARCHAR(128))
DECLARE @DimensionCombinedKeys TABLE (TableName NVARCHAR(128), ColumnName NVARCHAR(128), DimensionTable NVARCHAR(128), OrdinalPosition INT)
DECLARE @ColumnDefaults TABLE (DataType NVARCHAR(50),DefaultValue NVARCHAR(250))
DECLARE @PrimaryKeys TABLE (ColumnName NVARCHAR(128), OrdinalPosition INT)
DECLARE @ExistingPrimaryKeys TABLE (TableName NVARCHAR(128), ColumnName NVARCHAR(128))
DECLARE @CreatePrimaryKeys TABLE (ColumnName NVARCHAR(128), OrdinalPosition INT)
DECLARE @DropPrimaryKeys TABLE (ColumnName NVARCHAR(128), OrdinalPosition INT)
DECLARE @PrimaryDimensionKeys TABLE (ColumnName NVARCHAR(128), OrdinalPosition INT)
DECLARE @SCD2Columns TABLE (ColumnName NVARCHAR(128))
DECLARE @ExistingSCD2Columns TABLE (TableName NVARCHAR(128), ColumnName NVARCHAR(128))
DECLARE @CreateSCD2Columns TABLE (ColumnName NVARCHAR(128), OrdinalPosition INT)
DECLARE @DropSCD2Columns TABLE (ColumnName NVARCHAR(128), OrdinalPosition INT)
DECLARE @TableIsIncremental TABLE (TableName NVARCHAR(128))
DECLARE @ExistingTruncateProperty TABLE (TableName NVARCHAR(128))

/*Generates the combined information schema*/

INSERT @InformationSchema EXEC('--Create dataset with default constraints
								WITH DefaultConstraints AS
								(
								SELECT  objects.name AS TABLE_NAME 
										,all_columns.Name AS COLUMN_NAME
										,default_constraints.[name] AS DEFAULT_CONSTRAINT_NAME
								FROM 
									[' + @DatabaseNameDW + '].sys.default_constraints
								INNER JOIN 
									[' + @DatabaseNameDW + '].sys.objects
										ON objects.object_id = default_constraints.parent_object_id
								INNER JOIN 
									[' + @DatabaseNameDW + '].sys.all_columns 
										ON all_columns.object_id = objects.object_id
										AND all_columns.column_id = default_constraints.parent_column_id
								WHERE 
									objects.name = ''' + @Table + '''
								)
								
								SELECT  ''Stage'' AS DATABASE_NAME
										,COLUMNS.TABLE_NAME
										--If destinations shcema is fact or bridge key columns from stage is renamed to ID in order to compare column names
										,CASE 
											WHEN ''' + @DestinationSchema + ''' IN (''fact'',''bridge'') AND COLUMNS.COLUMN_NAME LIKE ''%' + @BusinessKeySuffix + ''' 
												THEN REPLACE(COLUMNS.COLUMN_NAME,''' + @BusinessKeySuffix + ''',''' + @SurrogateKeySuffix + ''') 
										    ELSE COLUMNS.COLUMN_NAME 
										 END AS COLUMN_NAME
										,COLUMNS.ORDINAL_POSITION
										,CASE 
											WHEN ''' + @DestinationSchema + ''' IN (''fact'',''bridge'') AND COLUMNS.COLUMN_NAME LIKE ''%' + @BusinessKeySuffix + ''' 
												THEN ''int'' 
											ELSE DATA_TYPE 
										 END AS DATA_TYPE
										,CHARACTER_MAXIMUM_LENGTH
										,NUMERIC_PRECISION
										,NUMERIC_SCALE
										,CASE 
											WHEN KEY_COLUMN_USAGE.COLUMN_NAME IS NULL 
												THEN 0 
										    ELSE 1 
										 END AS PRIMARY_KEY
										,DEFAULT_CONSTRAINT_NAME
								FROM 
									[' + @DatabaseNameStage + '].INFORMATION_SCHEMA.COLUMNS
								LEFT JOIN 
									[' + @DatabaseNameDW + '].INFORMATION_SCHEMA.KEY_COLUMN_USAGE
										ON COLUMNS.TABLE_NAME = KEY_COLUMN_USAGE.TABLE_NAME 
										AND COLUMNS.COLUMN_NAME = KEY_COLUMN_USAGE.COLUMN_NAME
								LEFT JOIN 
									DefaultConstraints
										ON COLUMNS.TABLE_NAME = DefaultConstraints.TABLE_NAME
										AND CASE WHEN ''' + @DestinationSchema + ''' IN (''fact'',''bridge'') AND COLUMNS.COLUMN_NAME LIKE ''%' + @BusinessKeySuffix + ''' THEN REPLACE(COLUMNS.COLUMN_NAME,''' + @BusinessKeySuffix + ''',''' + @SurrogateKeySuffix + ''') 
												 ELSE COLUMNS.COLUMN_NAME 
											END = DefaultConstraints.COLUMN_NAME
								WHERE 
										COLUMNS.TABLE_NAME = ''' + @Table + ''' 
									AND COLUMNS.COLUMN_NAME NOT LIKE ''DW%''
									AND COLUMNS.TABLE_SCHEMA = ''' + @StageSchema + '''

								UNION ALL

								SELECT ''DW'' AS DATABASE_NAME
										,COLUMNS.TABLE_NAME
										,COLUMNS.COLUMN_NAME
										,ORDINAL_POSITION
										,DATA_TYPE
										,CHARACTER_MAXIMUM_LENGTH
										,NUMERIC_PRECISION
										,NUMERIC_SCALE
										,0
										,DEFAULT_CONSTRAINT_NAME
								FROM 
									[' + @DatabaseNameDW + '].INFORMATION_SCHEMA.COLUMNS
								LEFT JOIN 
									DefaultConstraints
										ON COLUMNS.TABLE_NAME = DefaultConstraints.TABLE_NAME
										AND COLUMNS.COLUMN_NAME = DefaultConstraints.COLUMN_NAME
								WHERE 
										COLUMNS.TABLE_NAME = ''' + @Table + ''' 
									AND TABLE_SCHEMA = ''' + @DestinationSchema + ''' 
									AND COLUMNS.COLUMN_NAME NOT LIKE ''DW%''
									AND CASE WHEN ''' + @DestinationSchema + ''' <> ''bridge'' THEN COLUMNS.COLUMN_NAME 
									         ELSE ''1'' 
								        END <>
									    CASE WHEN ''' + @DestinationSchema + ''' <> ''bridge'' THEN ''' + @Table + '' + @SurrogateKeySuffix + ''' 
									         ELSE ''2'' 
										END')

INSERT @DWRelations EXEC meta.CreateDWRelations @Table					

/*Populates @DimensionCombinedKeys to check if combined keys are used and in which dimensions they are used*/

INSERT @DimensionCombinedKeys SELECT 
										DWRelations.TableName
									  ,	DWRelations.TableColumnName
									  ,	DWRelations.RolePlayingDimensionName
									  , InformationSchema.OrdinalPosition
									  
								FROM 
									@DWRelations AS DWRelations
								INNER JOIN
									@InformationSchema AS InformationSchema
										ON InformationSchema.ColumnName = REPLACE(DWRelations.TableColumnName,@BusinessKeySuffix,@SurrogateKeySuffix)
										AND InformationSchema.DatabaseName = 'Stage'
								WHERE --Only dimensions with composite keys are maintained
									DWRelations.RolePlayingDimensionName IN (
								SELECT 
										RolePlayingDimensionName
								FROM 
									@DWRelations
								WHERE 
									TableColumnName  LIKE RolePlayingDimensionName + '%'
								GROUP BY
										RolePlayingDimensionName
								HAVING
									COUNT(*) > 1)
								AND TableColumnName  LIKE RolePlayingDimensionName + '%'

INSERT @PrimaryDimensionKeys  EXEC('SELECT 
										 COLUMN_NAME
										,ROW_NUMBER() OVER (ORDER BY COLUMN_NAME) 
										
								FROM 
									[' + @DatabaseNameStage + '].INFORMATION_SCHEMA.COLUMNS
								WHERE 
									    TABLE_NAME = ''' + @Table + ''' 
									AND TABLE_SCHEMA = ''' + @StageSchema + '''
									AND COLUMN_NAME LIKE ''%Key''')
									
							

INSERT @ColumnDefaults EXEC('SELECT REPLACE([name],''Default'','''') AS DataType
								   ,CONVERT(NVARCHAR(128),value) AS DefaultValue
							 FROM 
								sys.extended_properties
							 WHERE 
								[name] IN (''DefaultDate'',''DefaultDimensionMemberID'',''DefaultNumber'',''DefaultString'',''DefaultBit'')')	

/*Populate table variables used foa assigning and removing extended column properties*/

INSERT @ExistingPrimaryKeys   EXEC('SELECT DISTINCT
										tables.name
									   ,all_columns.name 
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
									   extended_properties.name = ''PrimaryKeyColumn''
									   AND schemas.name = ''' + @DestinationSchema + '''
									   AND tables.name = ''' + @Table + '''')
								
INSERT @PrimaryKeys SELECT PrimaryKeyColumnName AS ColumnName,ROW_NUMBER() OVER (ORDER BY PrimaryKeyColumnName) AS OrdinalPosition FROM meta.BusinessMatrixIncrementalSetup INNER JOIN meta.BusinessMatrix ON BusinessMatrix.ID = BusinessMatrixIncrementalSetup.BusinessMatrixID WHERE BusinessMatrix.TableName = @Table AND BusinessMatrix.FactAndBridgeIncrementalFlag = 1	 

INSERT @CreatePrimaryKeys SELECT 
							 PK.ColumnName
						   , ROW_NUMBER() OVER (ORDER BY PK.ColumnName) AS OrdinalPosition 
						  FROM 
							@PrimaryKeys AS PK
						  LEFT JOIN 
							@ExistingPrimaryKeys AS Existing 
								ON Existing.ColumnName =  PK.ColumnName
						  WHERE 
							Existing.ColumnName IS NULL		

INSERT @DropPrimaryKeys	  SELECT 
							 Existing.ColumnName
						   , ROW_NUMBER() OVER (ORDER BY Existing.ColumnName) AS OrdinalPosition  
						  FROM 
							@ExistingPrimaryKeys AS Existing 
						  LEFT JOIN 
							@PrimaryKeys AS New 
								ON New.ColumnName = Existing.ColumnName 
						  WHERE 
							New.ColumnName IS NULL

INSERT @ExistingSCD2Columns   EXEC('SELECT DISTINCT
										tables.name
									   ,all_columns.name 
									FROM
									   [' + @DatabaseNameDW + '].sys.tables
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
									   AND tables.name = ''' + @Table + '''')

INSERT @SCD2Columns EXEC('WITH AllColumns AS

						  (
						  SELECT COLUMN_NAME COLLATE ' + @DatabaseCollation + ' AS COLUMN_NAME
						  FROM 
							[' + @DatabaseNameDW + '].INFORMATION_SCHEMA.COLUMNS
						  WHERE
							TABLE_SCHEMA = ''dim''
							AND TABLE_NAME = ''' + @Table + '''
							AND COLUMN_NAME NOT LIKE ''DW%''

						  )
						  
						  
						  
						  SELECT DISTINCT IIF(SCD2ColumnName = ''*'',COLUMN_NAME,SCD2ColumnName)
						  FROM 
							[meta].[BusinessMatrixSCD2Setup] 
						  INNER JOIN 
							[meta].[BusinessMatrix] 
								ON BusinessMatrixSCD2Setup.BusinessMatrixID = BusinessMatrix.ID
						  LEFT JOIN
							AllColumns
								ON SCD2ColumnName = ''*''
						  WHERE 
							TableName = ''' + @Table + '''
							AND DestinationSchema = ''dim''
							AND SCD2ColumnName <> ''''
							AND BusinessMatrix.SCD2DimensionFlag = 1')

INSERT @CreateSCD2Columns SELECT 
							 SCD2.ColumnName
						   , ROW_NUMBER() OVER (ORDER BY SCD2.ColumnName) AS OrdinalPosition 
						  FROM 
							@SCD2Columns AS SCD2
						  LEFT JOIN 
							@ExistingSCD2Columns AS Existing 
								ON Existing.ColumnName =  SCD2.ColumnName
						  WHERE 
							Existing.ColumnName IS NULL		

INSERT @DropSCD2Columns	  SELECT 
							 Existing.ColumnName
						   , ROW_NUMBER() OVER (ORDER BY Existing.ColumnName) AS OrdinalPosition  
						  FROM 
							@ExistingSCD2Columns AS Existing 
						  LEFT JOIN 
							@SCD2Columns AS New 
								ON New.ColumnName = Existing.ColumnName 
						  WHERE 
							New.ColumnName IS NULL

INSERT @TableIsIncremental   EXEC('SELECT DISTINCT
										tables.name
									FROM
									   [' + @DatabaseNameDW + '].sys.tables								
									INNER JOIN 
									   [' + @DatabaseNameDW + '].sys.extended_properties
											ON extended_properties.major_id=tables.object_id 
									WHERE
									   extended_properties.name = ''IncrementalFactOrBridgeFlag''
									   AND tables.name = ''' + @Table + '''')

							
INSERT @ExistingTruncateProperty EXEC('SELECT DISTINCT
											tables.name
									  FROM
										[' + @DatabaseNameDW + '].sys.tables									
										INNER JOIN
										[' + @DatabaseNameDW + '].sys.schemas
												ON 	schemas.schema_id = tables.schema_id	
										INNER JOIN
											[' + @DatabaseNameDW + '].sys.extended_properties AS TableProperties
											ON TableProperties.major_id=tables.object_id 										
											AND TableProperties.class=1
									  WHERE
											tables.name = ''' + @Table + '''
											AND TableProperties.name = ''TruncateBeforeDeploy''
											AND schemas.name = ''' + @DestinationSchema + '''')

										


/**********************************************************************************************************************************************************************
2. Create Loop counter variables
***********************************************************************************************************************************************************************/

DECLARE @Columns AS INT --Holds the number of columns in the table
DECLARE @Counter AS INT --Just a counter for the loop
DECLARE @NumberOfPrimaryKeyColumns INT
DECLARE @NumberOfPrimaryKeyColumnsToDrop AS INT --Holds the number of columns in the table
DECLARE @NumberOfPrimaryDimensionColumns AS INT --Holds the number of columns in the table
DECLARE @NumberOfSCD2Columns AS INT --Holds the number of columns in the table
DECLARE @NumberOfSCD2ColumnsToDrop AS INT --Holds the number of columns in the table
DECLARE @SCD2HistoryFromSourceKey BIT --If the dimension has the following columns DimensionNameIsCurrent, DimensionNameValidFromDate and DimensionNameValidToDate SCD2 history is created in the source

SELECT 
	@Columns = (SELECT MAX(OrdinalPosition) FROM @InformationSchema WHERE DatabaseName = 'Stage'), --Counts the number of columns in the table
	@Counter = 1,
	@NumberOfPrimaryKeyColumns = (SELECT MAX(OrdinalPosition) FROM @PrimaryKeys),
	@NumberOfPrimaryKeyColumnsToDrop = (SELECT MAX(OrdinalPosition) FROM @DropPrimaryKeys),
	@NumberOfPrimaryDimensionColumns = (SELECT MAX(OrdinalPosition) FROM @PrimaryDimensionKeys),
	@NumberOfSCD2Columns = (SELECT MAX(OrdinalPosition) FROM @CreateSCD2Columns),
	@NumberOfSCD2ColumnsToDrop = (SELECT MAX(OrdinalPosition) FROM @DropSCD2Columns),
	@SCD2HistoryFromSourceKey = (SELECT IIF(COUNT(ColumnName) = 3, 1, 0) FROM @InformationSchema WHERE REPLACE(ColumnName,@Table,'') IN ('IsCurrent', 'ValidFromDate', 'ValidToDate') AND DatabaseName = 'Stage' )


/**********************************************************************************************************************************************************************
3. Create variables for determine first change between stage and dw
***********************************************************************************************************************************************************************/

DECLARE @PositionFirstChangeNoCombinedKey INT --The ordinal position of the first change not looking at combined key columns
DECLARE @PositionFirstChangeCombinedKey INT --The ordinal position of the first change looking at combined Key columns
DECLARE @PositionFirstChange INT --The ordinal position of the first change
DECLARE @FirstNonKeyColumn INT --The ordinal position of the first non key column

SELECT
	@FirstNonKeyColumn = (SELECT TOP 1 OrdinalPosition FROM @InformationSchema WHERE DatabaseName = 'Stage' AND ColumnName NOT LIKE '%' + @SurrogateKeySuffix ORDER BY OrdinalPosition) ,
	@PositionFirstChangeNoCombinedKey = (SELECT TOP 1 Stage.OrdinalPosition
										 FROM 
											@InformationSchema AS Stage
										 LEFT JOIN 
											(SELECT * FROM @InformationSchema WHERE DatabaseName = 'DW') AS DW 
												ON Stage.ColumnName = DW.ColumnName
										 WHERE 
											Stage.DatabaseName = 'Stage' 
											AND DW.ColumnName IS NULL 
											AND (Stage.ColumnName NOT IN (SELECT REPLACE(ColumnName,@BusinessKeySuffix,@SurrogateKeySuffix) FROM @DimensionCombinedKeys))
										 ORDER BY Stage.OrdinalPosition
											), --Determines the position of the first change for non combined key columns


	@PositionFirstChangeCombinedKey = (SELECT TOP 1 OrdinalPosition 
									   FROM
											@DimensionCombinedKeys 
									   WHERE 
											DimensionTable + @SurrogateKeySuffix NOT IN (SELECT ColumnName FROM @InformationSchema WHERE DatabaseName = 'DW')
									   ORDER BY OrdinalPosition), --Determines the position for the first change for combined key columns


	@PositionFirstChange = CASE 
								WHEN @PositionFirstChangeNoCombinedKey IS NOT NULL AND @PositionFirstChangeNoCombinedKey > ISNULL(@PositionFirstChangeCombinedKey,1000) AND @DestinationSchema = 'fact' 
									THEN @PositionFirstChangeCombinedKey
    							WHEN @PositionFirstChangeNoCombinedKey IS NULL AND @DestinationSchema = 'fact' 
									THEN @PositionFirstChangeCombinedKey
								ELSE @PositionFirstChangeNoCombinedKey 
						   END --Determines the position of the first change

/**********************************************************************************************************************************************************************
4. Create new column names part
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderColumnNameUpdateTable AS NVARCHAR(MAX) 
DECLARE @ColumnNameUpdateTable AS NVARCHAR(MAX)

SET @Counter = @PositionFirstChange

WHILE @Counter <= @Columns

BEGIN

	SELECT @PlaceholderColumnNameUpdateTable = --Check if it is the first column 
											   CASE 
													WHEN Stage.OrdinalPosition = @PositionFirstChange 
														THEN ''
													ELSE ','
											   END 

											   +
											   --If the destination schema is bridge or fact key columns is handled seperatly
											   CASE 
													WHEN @DestinationSchema IN ('fact','bridge') AND Stage.ColumnName LIKE '%' + @SurrogateKeySuffix AND Stage.ColumnName NOT IN (SELECT ColumnName FROM @DimensionCombinedKeys)
														THEN  '[' + REPLACE(Stage.ColumnName,@BusinessKeySuffix,@SurrogateKeySuffix) + '] INT NOT NULL DEFAULT(' + (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DefaultDimensionMemberID') + ')'
													WHEN @DestinationSchema IN ('fact','bridge') AND Stage.ColumnName LIKE '%' + @SurrogateKeySuffix AND Stage.ColumnName IN (SELECT ColumnName FROM @DimensionCombinedKeys)
														THEN  '[' + (SELECT DISTINCT DimensionTable FROM @DimensionCombinedKeys AS Dimensions WHERE Stage.ColumnName = Dimensions.ColumnName) + @SurrogateKeySuffix +'] INT NOT NULL DEFAULT(' + (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DefaultDimensionMemberID') + ')'
													ELSE  '[' + Stage.ColumnName + '] ' + UPPER(Stage.DataType) + CASE 
																													  WHEN Stage.DataType LIKE '%int%' 
																														 THEN ''
																													  WHEN Stage.DataType IN ('nvarchar', 'varchar', 'nchar', 'char') AND Stage.CharacterMaximumLenght = -1 
																														 THEN '(MAX)'
																													  WHEN Stage.CharacterMaximumLenght IS NOT NULL 
																														 THEN ' (' + CAST(Stage.CharacterMaximumLenght AS NVARCHAR(50)) + ')'
																													  WHEN Stage.NumericPrecision IS NOT NULL 
																														 THEN ' (' + CAST(Stage.NumericPrecision AS NVARCHAR(50)) + ', ' + CAST(Stage.NumericScale AS NVARCHAR(50))+ ')'
																													  ELSE '' 
																												  END 																																										
											   END + CASE 
														WHEN @DestinationSchema IN ('fact','bridge') AND Stage.ColumnName IN (SELECT ColumnName FROM @PrimaryKeys)
															THEN ' NOT NULL'
														ELSE ''
													 END
                                      + @CRLF
				                
	FROM 
		@InformationSchema AS Stage
	LEFT JOIN 
		(SELECT * FROM @InformationSchema WHERE DatabaseName = 'DW') AS DW 
			ON Stage.ColumnName = DW.ColumnName
	WHERE 
			Stage.DatabaseName = 'Stage' 
		AND DW.ColumnName IS NULL 
		AND Stage.OrdinalPosition = @Counter 
		AND Stage.ColumnName NOT LIKE 'DW%' 
		
	SET @ColumnNameUpdateTable = CONCAT(@ColumnNameUpdateTable,CASE --If the column already exist in @ColumnNameUpdateTable or the DW table a blank is inserted into @ColumnNameUpdateTable
																	WHEN ISNULL(CHARINDEX (REPLACE(@PlaceholderColumnNameUpdateTable,',','') , @ColumnNameUpdateTable),0) <> 0 OR SUBSTRING(@PlaceholderColumnNameUpdateTable,CHARINDEX('[',@PlaceholderColumnNameUpdateTable,0)+1,CASE WHEN CHARINDEX(']',@PlaceholderColumnNameUpdateTable,0) = 0 THEN 0
																																																																						WHEN CHARINDEX(',',@PlaceholderColumnNameUpdateTable,0) = 0  THEN CHARINDEX(']',@PlaceholderColumnNameUpdateTable,0)-2
																																																																						ELSE CHARINDEX(']',@PlaceholderColumnNameUpdateTable,0)-3 
																																																																				   END ) IN (SELECT ColumnName FROM @InformationSchema WHERE DatabaseName = 'DW') THEN '' 
																	ELSE @PlaceholderColumnNameUpdateTable 
															   END)
	
	SET @PlaceholderColumnNameUpdateTable = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1


/**********************************************************************************************************************************************************************
5. Generates the columns for the alter datatype script. If there is a default constraint on the column, the constraint is dropped and recreated
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderColumnNameUpdateTableDataType AS NVARCHAR(MAX) 
DECLARE @ColumnNameUpdateTableDataType AS NVARCHAR(MAX) 

WHILE @Counter <= @Columns

BEGIN

	SELECT @PlaceholderColumnNameUpdateTableDataType = --If there is a constraint the constraint must be droppet
													   CASE 
															WHEN Stage.DefaultConstraintName IS NULL 
																THEN '' 
															ELSE 'ALTER TABLE [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].[' + @Table + '] '  + 'DROP CONSTRAINT [' + Stage.DefaultConstraintName + '] ' 
													   END 
												   
													   + @CRLF + 
													   --Alter the column
													   'ALTER TABLE [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].[' + @Table + '] '  + 'ALTER COLUMN [' + Stage.ColumnName + '] ' + UPPER(Stage.DataType) +   CASE 
																																																							   WHEN Stage.DataType LIKE '%int%' 
																																																								  THEN ''
																																																							   WHEN Stage.DataType IN ('nvarchar', 'varchar', 'nchar', 'char') AND Stage.CharacterMaximumLenght = -1 
																																																								  THEN '(MAX)'
																																																							   WHEN Stage.CharacterMaximumLenght IS NOT NULL 
																																																								  THEN ' (' + CAST(Stage.CharacterMaximumLenght AS NVARCHAR(50)) + ')'
																																																							   WHEN Stage.NumericPrecision IS NOT NULL 
																																																								  THEN ' (' + CAST(Stage.NumericPrecision AS NVARCHAR(50)) + ', ' + CAST(Stage.NumericScale AS NVARCHAR(50))+ ')'
																																																							   ELSE '' 
																																																						  END + CASE 
																																																									WHEN @DestinationSchema IN ('fact','bridge') AND Stage.ColumnName IN (SELECT ColumnName FROM @PrimaryKeys) 
																																																										THEN ' NOT NULL'
																																																									ELSE ''
																																																								END 
												  
													   + @CRLF +
													   --Add the constraint again
													   CASE 
															WHEN Stage.DefaultConstraintName IS NULL 
																THEN '' 
															ELSE 'ALTER TABLE [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].[' + @Table + '] '  + ISNULL('ADD CONSTRAINT [' + Stage.DefaultConstraintName + '] DEFAULT (''' + (SELECT DefaultValue FROM @ColumnDefaults WHERE DataType = CASE WHEN Stage.DataType LIKE 'Date%' THEN 'Date' 
																																																																								   WHEN Stage.DataType LIKE '%char%' THEN 'String'
																																																																								   WHEN Stage.DataType = 'bit' THEN 'Bit'
																																																																								   ELSE 'Number'
																																																																								END) + ''') FOR [' + Stage.ColumnName + ']','')
																																			  
													   END 
												   
													   + @CRLF
                                   
	FROM 
		@InformationSchema Stage
	WHERE 
			Stage.DatabaseName = 'Stage' 
		AND Stage.OrdinalPosition = @Counter 
		AND Stage.ColumnName NOT LIKE '%' + @SurrogateKeySuffix
		AND Stage.PrimaryKey = 0

	SET @ColumnNameUpdateTableDataType = CONCAT(@ColumnNameUpdateTableDataType,@PlaceholderColumnNameUpdateTableDataType)

	SET @PlaceholderColumnNameUpdateTableDataType = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
6. Create Primary Key Columns
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderPrimaryKeyColumns NVARCHAR(MAX)
DECLARE @PrimaryKeyColumns NVARCHAR(MAX)

WHILE @Counter <= @NumberOfPrimaryKeyColumns

BEGIN

	SELECT @PlaceholderPrimaryKeyColumns = CASE WHEN @Counter = 1 THEN '' ELSE ',' END + ColumnName
	FROM 
		@PrimaryKeys
	WHERE
		OrdinalPosition = @Counter

SET @PrimaryKeyColumns = CONCAT(@PrimaryKeyColumns,@PlaceholderPrimaryKeyColumns)

SET @PlaceholderPrimaryKeyColumns = ''

SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
7. Create Primary Key Columns
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderPrimaryDimensionKeyColumns NVARCHAR(MAX)
DECLARE @PrimaryDimensionKeyColumns NVARCHAR(MAX)

WHILE @Counter <= @NumberOfPrimaryDimensionColumns

BEGIN

	SELECT @PlaceholderPrimaryDimensionKeyColumns = CASE WHEN @Counter = 1 THEN '' ELSE ',' END + ColumnName
	FROM 
		@PrimaryDimensionKeys
	WHERE
		OrdinalPosition = @Counter

SET @PrimaryDimensionKeyColumns = CONCAT(@PrimaryDimensionKeyColumns,@PlaceholderPrimaryDimensionKeyColumns)

SET @PlaceholderPrimaryDimensionKeyColumns = ''

SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
8. Drop SCD2 properties
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderSCD2Drop NVARCHAR(MAX)
DECLARE @SCD2Drop NVARCHAR(MAX)

WHILE @Counter <= @NumberOfSCD2ColumnsToDrop

BEGIN

	SELECT @PlaceholderSCD2Drop = 'EXEC [' + @DatabaseNameDW + '].sys.sp_dropextendedproperty @name=N''SCDColumn'',@level0type = N''Schema'', @level0name = ''dim'' ,@level1type = N''Table'',  @level1name = ''' + @Table + ''' ,@level2type = N''Column'', @level2name = ''' + ColumnName + '''' + @CRLF
	FROM 
		@DropSCD2Columns
	WHERE
		OrdinalPosition = @Counter

SET @SCD2Drop = CONCAT(@SCD2Drop,@PlaceholderSCD2Drop)

SET @PlaceholderSCD2Drop = ''

SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
9. Create SCD2 properties
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderSCD2Create NVARCHAR(MAX)
DECLARE @SCD2Create NVARCHAR(MAX)

WHILE @Counter <= @NumberOfSCD2Columns

BEGIN

	SELECT @PlaceholderSCD2Create = 'EXEC [' + @DatabaseNameDW + '].sys.sp_addextendedproperty @name=N''SCDColumn'', @value=N''SCD2'' ,@level0type = N''Schema'', @level0name = ''dim'' ,@level1type = N''Table'',  @level1name = ''' + @Table + ''' ,@level2type = N''Column'', @level2name = ''' + ColumnName + '''' + @CRLF
	FROM 
		@CreateSCD2Columns
	WHERE
		OrdinalPosition = @Counter

SET @SCD2Create = CONCAT(@SCD2Create,@PlaceholderSCD2Create)

SET @PlaceholderSCD2Create = ''

SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
10. Drop PK properties
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderPKDrop NVARCHAR(MAX)
DECLARE @PKDrop NVARCHAR(MAX)

WHILE @Counter <= @NumberOfPrimaryKeyColumnsToDrop

BEGIN

	SELECT @PlaceholderPKDrop = 'EXEC [' + @DatabaseNameDW + '].sys.sp_dropextendedproperty @name=N''PrimaryKeyColumn'',@level0type = N''Schema'', @level0name = ''' + @DestinationSchema + ''' ,@level1type = N''Table'',  @level1name = ''' + @Table + ''' ,@level2type = N''Column'', @level2name = ''' + ColumnName + '''' + @CRLF
	FROM 
		@DropPrimaryKeys
	WHERE
		OrdinalPosition = @Counter

SET @PKDrop = CONCAT(@PKDrop,@PlaceholderPKDrop)

SET @PlaceholderPKDrop = ''

SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
11. Create PK properties
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderPKCreate NVARCHAR(MAX)
DECLARE @PKCreate NVARCHAR(MAX)

WHILE @Counter <= @NumberOfPrimaryKeyColumns

BEGIN

	SELECT @PlaceholderPKCreate = 'EXEC [' + @DatabaseNameDW + '].sys.sp_addextendedproperty @name=N''PrimaryKeyColumn'', @value=N''PK'' ,@level0type = N''Schema'', @level0name = ''' + @DestinationSchema + ''' ,@level1type = N''Table'',  @level1name = ''' + @Table + ''' ,@level2type = N''Column'', @level2name = ''' + ColumnName + '''' + @CRLF
	FROM 
		@CreatePrimaryKeys
	WHERE
		OrdinalPosition = @Counter

SET @PKCreate = CONCAT(@PKCreate,@PlaceholderPKCreate)

SET @PlaceholderPKCreate = ''

SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
12. Fill out the dynamic SQL script variables
***********************************************************************************************************************************************************************/

DECLARE @UpdateTableScript NVARCHAR(MAX) --Variable for the final alter table script for adding columns
DECLARE @UpdatePrimaryKeyScript NVARCHAR(MAX) --Variable for the final create fact primary key script
DECLARE @UpdatePrimaryDimensionKeyScript NVARCHAR(MAX) --Variable for the final create fact primary key script
DECLARE @UpdateDataTypesScript AS NVARCHAR(MAX) --Variable for the final alter table script for changing columns
DECLARE @UpdateIncrementalFlag NVARCHAR(MAX)
DECLARE @DropTruncateBeforeDeploy NVARCHAR(MAX)
DECLARE @CreateTruncateBeforeDeploy NVARCHAR(MAX)

SET @UpdateTableScript = CASE 
							WHEN @PositionFirstChange IS NULL 
								THEN NULL 
							ELSE 'ALTER TABLE [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].[' + @Table + ']'  + CHAR(13) + CHAR(10) + 'ADD ' + @ColumnNameUpdateTable 
						 END

SET @UpdatePrimaryKeyScript = IIF(@IsCloudFlag = 1,'','USE [' + @DatabaseNameDW + ']') + @CRLF + 'IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id(''' + @DestinationSchema + '.' + @Table + ''') AND NAME = ''PK_'+ @Table + ''')
							   BEGIN
							   ALTER TABLE  [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].[' + @Table + ']' + @CRLF +
							   'ADD CONSTRAINT PK_' + @Table + ' PRIMARY KEY NONCLUSTERED (' + @PrimaryKeyColumns + ')' + @CRLF +
							   'END'

SET @UpdatePrimaryDimensionKeyScript = IIF(@IsCloudFlag = 1,'','USE [' + @DatabaseNameDW + ']') + @CRLF + 							   
							   'DROP INDEX NCI_' + @Table + ' ON ' + '[' + @DatabaseNameDW + '].[' + @DestinationSchema + '].[' + @Table + ']'  + @CRLF +
							   'CREATE NONCLUSTERED INDEX NCI_' + @Table + ' ON ' +  '[' + @DatabaseNameDW + '].[' + @DestinationSchema + '].[' + @Table + '] (' + @PrimaryDimensionKeyColumns + IIF(@SCD2HistoryFromSourceKey = 1,',' + @Table + 'ValidFromDate)',',DWValidFromDate)') + @CRLF 

SET @UpdateDataTypesScript = @ColumnNameUpdateTableDataType

SET @UpdateIncrementalFlag = IIF(NOT EXISTS (SELECT * FROM @TableIsIncremental) AND @FactIsIncremental = 1,'EXEC [' + @DatabaseNameDW + '].sys.sp_addextendedproperty @name=N''IncrementalFactOrBridgeFlag'', @value=N''1'' ,@level0type = N''Schema'', @level0name = ''' + @DestinationSchema + ''' ,@level1type = N''Table'',  @level1name = ''' + @Table + '''','')
	
SET @DropTruncateBeforeDeploy = IIF(EXISTS(SELECT * FROM @ExistingTruncateProperty),'EXEC [' + @DatabaseNameDW + '].sys.sp_dropextendedproperty @name=N''TruncateBeforeDeploy'',@level0type = N''Schema'', @level0name = ''' + @DestinationSchema + ''' ,@level1type = N''Table'',  @level1name = ''' + @Table + '''','')
SET @CreateTruncateBeforeDeploy = IIF(@CreateTruncateProperty = 1,'EXEC [' + @DatabaseNameDW + '].sys.sp_addextendedproperty @name=N''TruncateBeforeDeploy'',@value = N''True'',@level0type = N''Schema'', @level0name = ''' + @DestinationSchema + ''' ,@level1type = N''Table'',  @level1name = ''' + @Table + '''','')

/**********************************************************************************************************************************************************************
13. Execute dynamic SQL
***********************************************************************************************************************************************************************/

IF @PrintSQL = 0

	BEGIN

		--If an NOT NULL column is added to a fact or bridge the destination table is truncated
		IF @UpdateTableScript LIKE '%NOT NULL%' OR @UpdateTableScript LIKE '%Key]%'--Tables where a NOT NULL column is addded
			BEGIN 
				EXEC('DROP TABLE [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].[' + @Table + ']')  
				EXEC meta.[MaintainDWCreateTableAndView] @Table, @DestinationSchema, 0
			END
		ELSE 
			BEGIN
				EXEC(@UpdateTableScript)
				EXEC(@UpdateIncrementalFlag)
				EXEC(@SCD2Drop)
				EXEC(@SCD2Create)
				EXEC(@PKDrop)
				EXEC(@PKCreate)
				EXEC(@UpdateDataTypesScript)
				EXEC(@DropTruncateBeforeDeploy)
				EXEC(@CreateTruncateBeforeDeploy)
			END

		IF @FactIsIncremental = 1 AND  @PrimaryKeyColumns IS NOT NULL AND @LoadPattern = 'Standard'
			BEGIN
				EXEC(@UpdatePrimaryKeyScript)
			END

	END

ELSE

	BEGIN
		
		IF @UpdateTableScript LIKE '%NOT NULL%' OR @UpdateTableScript LIKE '%Key]%'--Tables where a NOT NULL column is addded
			BEGIN 
				PRINT('DROP TABLE [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].[' + @Table + ']')  + @CRLF + @CRLF
				EXEC meta.[MaintainDWCreateTableAndView] @Table, @DestinationSchema, 1 
			END
		ELSE 
			BEGIN
				PRINT(@UpdateTableScript) + @CRLF + @CRLF
				PRINT(@UpdateIncrementalFlag) + @CRLF + @CRLF
				PRINT(@SCD2Drop) + @CRLF + @CRLF
				PRINT(@SCD2Create) + @CRLF + @CRLF
				PRINT(@PKDrop) + @CRLF + @CRLF
				PRINT(@PKCreate) + @CRLF + @CRLF
				PRINT(@UpdateDataTypesScript)  + @CRLF + @CRLF
				PRINT(@DropTruncateBeforeDeploy)  + @CRLF + @CRLF
				PRINT(@CreateTruncateBeforeDeploy)  + @CRLF + @CRLF
			END

		IF @FactIsIncremental = 1 AND  @PrimaryKeyColumns IS NOT NULL AND @LoadPattern = 'Standard'
			BEGIN
				PRINT(@UpdatePrimaryKeyScript) + @CRLF + @CRLF
			END

	END

SET NOCOUNT OFF
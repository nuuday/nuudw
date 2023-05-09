

/**********************************************************************************************************************************************************************
The purpose of this scripts is to create and execute the create table and create view script between stage and dw. 
***********************************************************************************************************************************************************************/



CREATE PROCEDURE [meta].[MaintainDWCreateTableAndView]

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
DECLARE @SurrogatKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'SurrogateKeySuffix')
DECLARE @BusinessKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'BusinessKeySuffix')
DECLARE @FactIsIncremental BIT = (SELECT FactAndBridgeIncrementalFlag FROM meta.BusinessMatrix WHERE TableName = @Table AND DestinationSchema = @DestinationSchema)
DECLARE @CompatibilityLevel INT = (SELECT compatibility_level FROM sys.databases WHERE name COLLATE DANISH_NORWEGIAN_CI_AS = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameDW'))
DECLARE @SQLEnterpriseServer BIT = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'EnterpriseEditionFlag')
DECLARE @LoadPattern NVARCHAR(50) = (SELECT LoadPattern FROM meta.BusinessMatrix WHERE TableName = @Table)
DECLARE @FactCCIFlag BIT = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'FactCCIFlag')
DECLARE @FactInMemoryFlag BIT = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'FactInMemoryFlag')
DECLARE @FactEngineIsSQLFlag BIT = IIF((SELECT VariableValue FROM meta.Variables WHERE VariableName = 'FactLoadEngine') = 'SQL',1,0)
DECLARE @UpdateViewFlag BIT = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'MaintainDWUpdateViewFlag')
DECLARE @ViewName NVARCHAR(100) = meta.[SplitCamelCase](@Table)
DECLARE @IsCloudFlag BIT = IIF((SELECT VariableValue FROM meta.Variables WHERE VariableName = 'IsCloudFlag') = '1',1,0)
DECLARE @IsSingleDatabase BIT = IIF(@DatabaseNameMeta = @DatabaseNameDW,1,0)
DECLARE @StageSchemaTable TABLE (SchemaName NVARCHAR(10)) 
INSERT @StageSchemaTable EXEC('SELECT DISTINCT TABLE_SCHEMA FROM [' + @DatabaseNameStage + '].INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @Table + ''' AND TABLE_SCHEMA IN (''dbo'',''stage'')')
DECLARE @StageSchema NVARCHAR(10) = (SELECT IIF(@IsCloudFlag = 1,'stage',(SELECT SchemaName FROM @StageSchemaTable))) --If on-premise and stageschema has not been changed
DECLARE @DatabaseCollation NVARCHAR(100) = (SELECT CONVERT (varchar, DATABASEPROPERTYEX('' + @DatabaseNameMeta + '','collation')))
DECLARE @TruncateFlag BIT = (SELECT TruncateBeforeDeployFlag FROM meta.BusinessMatrix WHERE TableName = @Table AND DestinationSchema = @DestinationSchema)


/**********************************************************************************************************************************************************************
1. Create and insert data into table variables
***********************************************************************************************************************************************************************/

DECLARE @TableExists TABLE (TableName NVARCHAR(50)) --Table variable used to check if the table exists in the DW
DECLARE @ViewExists TABLE (TableName NVARCHAR(50)) --Table variable used to check if the table exists in the DW
DECLARE @TempViewExists TABLE (TableName NVARCHAR(50)) --Table variable used to check if the table exists in the DW
DECLARE @TempTableExists TABLE (TableName NVARCHAR(50)) --Table variable used to check if the table exists in the DW
DECLARE @InformationSchema TABLE (DatabaseName NVARCHAR(128), TableName NVARCHAR(128), ColumnName NVARCHAR(128), OrdinalPosition INT, DataType NVARCHAR(128), CharacterMaximumLenght INT, NumericPrecision INT, NumericScale INT)
DECLARE @DWRelations TABLE (TableName NVARCHAR(128), DimensionName NVARCHAR(128), TableColumnName NVARCHAR(128), DimensionColumnMappingName NVARCHAR(128), RolePlayingDimensionName NVARCHAR(128), IsSCD2DimensionFlag NVARCHAR(10), IsSCD2CompositeKeyDimensionFlag NVARCHAR(10), ColumnOrdinalPosition INT, IsNewDimensionFlag NVARCHAR(128), DefaultErrorValue NVARCHAR(128))
DECLARE @DimensionCombinedKeys TABLE (TableName NVARCHAR(128), ColumnName NVARCHAR(128), DimensionTable NVARCHAR(128))
DECLARE @PrimaryKeys TABLE (ColumnName NVARCHAR(128), OrdinalPosition INT)
DECLARE @PrimaryDimensionKeys TABLE (ColumnName NVARCHAR(128), OrdinalPosition INT)
DECLARE @SCD2Columns TABLE (ColumnName NVARCHAR(128), OrdinalPosition INT)

/*Generates a dataset with the combined information schema*/

INSERT @InformationSchema EXEC('SELECT 
										 ''Stage'' AS DATABASE_NAME
										,TABLE_NAME
										,COLUMN_NAME
										,ORDINAL_POSITION
										,DATA_TYPE
										,CHARACTER_MAXIMUM_LENGTH
										,NUMERIC_PRECISION
										,NUMERIC_SCALE
								FROM 
									[' + @DatabaseNameStage + '].INFORMATION_SCHEMA.COLUMNS
								WHERE 
									    TABLE_NAME = ''' + @Table + ''' 
									AND COLUMN_NAME NOT LIKE ''DW%''
									AND TABLE_SCHEMA = ''' + @StageSchema + '''')


/*Populates @TableExists and @ViewExists to check if table or View exists or not*/

INSERT @TableExists       EXEC('SELECT 
										TABLE_NAME 
						        FROM 
									[' + @DatabaseNameDW + '].INFORMATION_SCHEMA.TABLES 
								 WHERE 
									    TABLE_NAME = ''' + @Table + ''' 
									AND TABLE_SCHEMA = ''' + @DestinationSchema + '''')

INSERT @ViewExists		  EXEC('SELECT 
										TABLE_NAME 
								FROM 
									[' + @DatabaseNameDW + '].INFORMATION_SCHEMA.TABLES 
								WHERE 
										TABLE_NAME = ''' + @ViewName + ''' 
									AND TABLE_SCHEMA = ''' + @DestinationSchema + 'View''')

INSERT @TempViewExists		  EXEC('SELECT 
										TABLE_NAME 
								FROM 
									[' + @DatabaseNameDW + '].INFORMATION_SCHEMA.TABLES 
								WHERE 
										TABLE_NAME = ''' + @ViewName + '_Temp'' 
									AND TABLE_SCHEMA = ''' + @DestinationSchema + 'View''')

INSERT @TempTableExists       EXEC('SELECT 
										TABLE_NAME 
						        FROM 
									[' + @DatabaseNameDW + '].INFORMATION_SCHEMA.TABLES 
								 WHERE 
									    TABLE_NAME = ''' + @Table + '_Temp'' 
									AND TABLE_SCHEMA = ''' + @DestinationSchema + '''')

INSERT @PrimaryKeys SELECT PrimaryKeyColumnName AS ColumnName,ROW_NUMBER() OVER (ORDER BY PrimaryKeyColumnName) AS OrdinalPosition FROM meta.BusinessMatrixIncrementalSetup INNER JOIN meta.BusinessMatrix ON BusinessMatrix.ID = BusinessMatrixIncrementalSetup.BusinessMatrixID WHERE BusinessMatrix.TableName = @Table

INSERT @PrimaryDimensionKeys SELECT ColumnName,ROW_NUMBER() OVER (ORDER BY ColumnName) AS OrdinalPosition FROM @InformationSchema WHERE ColumnName LIKE '%' + @BusinessKeySuffix

INSERT @DWRelations EXEC meta.CreateDWRelations @Table		

INSERT @SCD2Columns EXEC('WITH AllColumns AS

						  (
						  SELECT COLUMN_NAME COLLATE ' + @DatabaseCollation + ' AS COLUMN_NAME
						  FROM 
							[' + @DatabaseNameStage + '].INFORMATION_SCHEMA.COLUMNS
						  WHERE
							TABLE_NAME = ''' + @Table + '''
							AND COLUMN_NAME NOT LIKE ''DW%''

						  )
						  
						  
						  
						  SELECT 
								 IIF(SCD2ColumnName = ''*'',COLUMN_NAME,SCD2ColumnName)
								,ROW_NUMBER() OVER ( ORDER BY IIF(SCD2ColumnName = ''*'',COLUMN_NAME,SCD2ColumnName))
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
							AND BusinessMatrix.SCD2DimensionFlag = 1
						  GROUP BY 
							IIF(SCD2ColumnName = ''*'',COLUMN_NAME,SCD2ColumnName)')
						
/*Populates @DimensionCombinedKeys to check if combined keys are used and in which dimensions they are used*/

INSERT @DimensionCombinedKeys  SELECT 
										TableName
									  ,	TableColumnName
									  ,	RolePlayingDimensionName
																  
								FROM 
									@DWRelations						
								WHERE --Only dimensions with composite keys are maintained
									RolePlayingDimensionName IN (
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
								
							
						
/**********************************************************************************************************************************************************************
2. Create Loop counter variables
***********************************************************************************************************************************************************************/

DECLARE @Counter AS INT --Just a counter for the loop		
DECLARE @NumberOfColumns AS INT --Holds the number of columns in the table
DECLARE @NumberOfPrimaryColumns AS INT --Holds the number of columns in the table
DECLARE @NumberOfPrimaryDimensionColumns AS INT --Holds the number of columns in the table
DECLARE @NumberOfSCD2Columns AS INT --Holds the number of columns in the table
DECLARE @SCD2HistoryFromSourceKey BIT --If the dimension has the following columns DimensionNameIsCurrent, DimensionNameValidFromDate and DimensionNameValidToDate SCD2 history is created in the source
								
SELECT 
	@Counter = 1,
	@NumberOfColumns = (SELECT MAX(OrdinalPosition) FROM @InformationSchema),
	@NumberOfPrimaryColumns = (SELECT MAX(OrdinalPosition) FROM @PrimaryKeys),
	@NumberOfPrimaryDimensionColumns = (SELECT MAX(OrdinalPosition) FROM @PrimaryDimensionKeys),
	@NumberOfSCD2Columns = (SELECT MAX(OrdinalPosition) FROM @SCD2Columns),
	@SCD2HistoryFromSourceKey = (SELECT IIF(COUNT(ColumnName) = 3, 1, 0) FROM @InformationSchema WHERE REPLACE(ColumnName,@Table,'') IN ('IsCurrent', 'ValidFromDate', 'ValidToDate') AND DatabaseName = 'Stage' )



/**********************************************************************************************************************************************************************
3. Create Auditcolumn variable
***********************************************************************************************************************************************************************/

DECLARE @AuditColumns NVARCHAR(MAX) = CASE 
										  WHEN @DestinationSchema = 'dim' 
											  THEN ',[DWIsCurrent] BIT NOT NULL' + @CRLF + ',[DWValidFromDate] DATETIME NOT NULL' + @CRLF + ',[DWValidToDate] DATETIME NOT NULL' + @CRLF + ',[DWCreatedDate] DATETIME NOT NULL' + @CRLF + ',[DWModifiedDate] DATETIME NOT NULL' + @CRLF + ',[DWIsDeleted] BIT NOT NULL'
										  ELSE ',[DWCreatedDate] DATETIME NOT NULL' + @CRLF + ',[DWModifiedDate] DATETIME NOT NULL'
									  END


/**********************************************************************************************************************************************************************
4. Generates the columns for the create table script
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderColumnNameCreateTable AS NVARCHAR(MAX) 
DECLARE @ColumnNameCreateTable AS NVARCHAR(MAX) 


BEGIN

WHILE @Counter <= @NumberOfColumns

BEGIN

	SELECT @PlaceholderColumnNameCreateTable =
											--Check if it is the first column
											   CASE 
													WHEN OrdinalPosition = 1 
														THEN ''
													ELSE ','
											   END 
											   
											   + 
											--If the destination schema is bridge or fact key columns are converted to ID with datatype int with the default value stated in application.Variables  
											   CASE 
													WHEN @DestinationSchema IN ('fact','bridge') AND ColumnName LIKE '%' + @BusinessKeySuffix AND ColumnName NOT IN (SELECT ColumnName FROM @DimensionCombinedKeys) 
														THEN  '[' + REPLACE(ColumnName,@BusinessKeySuffix,@SurrogatKeySuffix) + '] INT NOT NULL DEFAULT(' + (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DefaultDimensionMemberID') + ')'
													WHEN @DestinationSchema IN ('fact','bridge') AND ColumnName LIKE '%' + @BusinessKeySuffix AND ColumnName IN (SELECT ColumnName FROM @DimensionCombinedKeys) 
														THEN  '[' + (SELECT DISTINCT DimensionTable FROM @DimensionCombinedKeys AS Dimension WHERE InformationSchema.ColumnName = Dimension.ColumnName) + @SurrogatKeySuffix + '] INT NOT NULL DEFAULT(' + (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DefaultDimensionMemberID') + ')'
											--If not column datatypes are maintained with the default value stated in application.Variables  
													ELSE  '[' + ColumnName + '] ' + UPPER(DataType) +  CASE 
																											WHEN DataType LIKE '%int%' OR DataType LIKE '%float%' 
																												THEN ''
																											WHEN DataType IN ('nvarchar', 'varchar', 'nchar', 'char') AND CharacterMaximumLenght = -1 
																												THEN '(MAX)'
																											WHEN CharacterMaximumLenght IS NOT NULL 
																												THEN ' (' + CAST(CharacterMaximumLenght AS NVARCHAR(50)) + ')'
																											WHEN NumericPrecision IS NOT NULL 
																												THEN ' (' + CAST(NumericPrecision AS NVARCHAR(50)) + ', ' + CAST(NumericScale AS NVARCHAR(50))+ ')'
																											ELSE '' 
																										END + CASE
																												 WHEN @DestinationSchema IN ('fact','bridge') AND InformationSchema.ColumnName IN (SELECT ColumnName FROM @PrimaryKeys) 
																													THEN ' NOT NULL'
																												 ELSE ''
																											  END
																												
												
											   END
																				
												+ 
											   @CRLF 
                                    
	FROM 
		@InformationSchema AS InformationSchema
	WHERE 
		OrdinalPosition = @Counter

	SET @ColumnNameCreateTable = CONCAT(@ColumnNameCreateTable,CASE WHEN ISNULL( CHARINDEX (REPLACE(@PlaceholderColumnNameCreateTable,',','') , @ColumnNameCreateTable),0) <> 0 THEN '' ELSE @PlaceholderColumnNameCreateTable END)

	SET @PlaceholderColumnNameCreateTable = ''

	SET @Counter = @Counter + 1

END



SET @Counter = 1


/**********************************************************************************************************************************************************************
5. Generates the columns for the create view script
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderColumnNameCreateView AS NVARCHAR(MAX) 
DECLARE @ColumnNameCreateView AS NVARCHAR(MAX) 

WHILE @Counter <= @NumberOfColumns

BEGIN

	SELECT @PlaceholderColumnNameCreateView = 
											  --Check if it is the first column
											  CASE 
												 WHEN OrdinalPosition = 1 
													THEN ''
												 ELSE ','
											  END 
											  
											  + 
											  --If the destination schema is bridge or fact key columns are converted to ID.  
											  CASE 
												WHEN @DestinationSchema IN ('fact','bridge') AND ColumnName LIKE '%' + @BusinessKeySuffix AND ColumnName NOT IN (SELECT ColumnName FROM @DimensionCombinedKeys) 
													THEN '[' + REPLACE(ColumnName,@BusinessKeySuffix,@SurrogatKeySuffix) + '] '
												WHEN @DestinationSchema IN ('fact','bridge') AND ColumnName LIKE '%' + @BusinessKeySuffix AND ColumnName IN (SELECT ColumnName FROM @DimensionCombinedKeys) 
													THEN  '[' + (SELECT DISTINCT DimensionTable FROM @DimensionCombinedKeys AS Dimension WHERE InformationSchema.ColumnName = Dimension.ColumnName) + @SurrogatKeySuffix + ']' 
											  --If not the column is given an alias where the name is splited on upper characters
											  	WHEN (@DestinationSchema IN ('fact','bridge') AND (ColumnName LIKE '%Code' OR ColumnName LIKE '%Name' OR ColumnName LIKE '%Label')) OR (@DestinationSchema = 'dim' AND ColumnName NOT LIKE '%' + @SurrogatKeySuffix)
													THEN '[' + ColumnName + '] AS [' + meta.SplitCamelCase(ColumnName) +']'
												ELSE '[' + ColumnName + ']'
											  END

											  +

											  @CRLF							  
											  											
	FROM 
		@InformationSchema AS InformationSchema
	WHERE 
		OrdinalPosition = @Counter

	SET @ColumnNameCreateView = CONCAT(@ColumnNameCreateView,CASE WHEN ISNULL( CHARINDEX (REPLACE(@PlaceholderColumnNameCreateView,',','') , @ColumnNameCreateView),0) <> 0 THEN '' ELSE @PlaceholderColumnNameCreateView END)

	SET @PlaceholderColumnNameCreateView = ''

	SET @Counter = @Counter + 1

END


SET @Counter = 1

/**********************************************************************************************************************************************************************
6. Create Primary Key Columns
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderPrimaryKeyColumns NVARCHAR(MAX)
DECLARE @PrimaryKeyColumns NVARCHAR(MAX)
DECLARE @PlaceholderPrimaryKeyColumnsExtended NVARCHAR(MAX)
DECLARE @PrimaryKeyColumnsExtended NVARCHAR(MAX)

WHILE @Counter <= @NumberOfPrimaryColumns

BEGIN

	SELECT 
		 @PlaceholderPrimaryKeyColumns = CASE WHEN @Counter = 1 THEN '' ELSE ',' END + ColumnName
		,@PlaceholderPrimaryKeyColumnsExtended = 'EXEC [' + @DatabaseNameDW + '].sys.sp_addextendedproperty @name=N''PrimaryKeyColumn'', @value=N''PK'' ,@level0type = N''Schema'', @level0name = ''' + @DestinationSchema + ''' ,@level1type = N''Table'',  @level1name = ''' + @Table + ''' ,@level2type = N''Column'', @level2name = ''' + ColumnName + '''' + @CRLF
	FROM 
		@PrimaryKeys
	WHERE
		OrdinalPosition = @Counter

SET @PrimaryKeyColumns = CONCAT(@PrimaryKeyColumns,@PlaceholderPrimaryKeyColumns)
SET @PrimaryKeyColumnsExtended = CONCAT(@PrimaryKeyColumnsExtended,@PlaceholderPrimaryKeyColumnsExtended)

SET @PlaceholderPrimaryKeyColumns = ''
SET @PlaceholderPrimaryKeyColumnsExtended = ''

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
8. Create SCD2 columns
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderSCD2 NVARCHAR(MAX)
DECLARE @SCD2 NVARCHAR(MAX)

WHILE @Counter <= @NumberOfSCD2Columns

BEGIN

	SELECT @PlaceholderSCD2 = 'EXEC [' + @DatabaseNameDW + '].sys.sp_addextendedproperty @name=N''SCDColumn'', @value=N''SCD2'' ,@level0type = N''Schema'', @level0name = ''dim'' ,@level1type = N''Table'',  @level1name = ''' + @Table + ''' ,@level2type = N''Column'', @level2name = ''' + ColumnName + '''' + @CRLF
	FROM 
		@SCD2Columns
	WHERE
		OrdinalPosition = @Counter

SET @SCD2 = CONCAT(@SCD2,@PlaceholderSCD2)

SET @PlaceholderSCD2 = ''

SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
9. Fill out the dynamic SQL script variables
***********************************************************************************************************************************************************************/

DECLARE @CreateTableScript AS NVARCHAR(MAX) 
DECLARE @CreateTempTableScript AS NVARCHAR(MAX) 
DECLARE @CreateClusteredColumnStoreIndexScript NVARCHAR(MAX)
DECLARE @PrepareViewScript AS NVARCHAR(MAX) 
DECLARE @CreateViewScript NVARCHAR(MAX) 
DECLARE @PrepareTempViewScript AS NVARCHAR(MAX) 
DECLARE @CreateTempViewScript NVARCHAR(MAX) 
DECLARE @CreateIncrementalProperty NVARCHAR(MAX)
DECLARE @CreateTruncateProperty NVARCHAR(MAX)
DECLARE @CreateTruncatePropertyTemp NVARCHAR(MAX)

/*Generates the final create table script*/

SET @CreateTableScript = 'CREATE TABLE [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].[' + @Table + ']' + @CRLF +
'(' + @CRLF +
CASE WHEN @DestinationSchema IN ('fact','bridge') THEN '' 
	 ELSE ' [' + @Table + @SurrogatKeySuffix + '] INT IDENTITY PRIMARY KEY' + @CRLF + ',' 
END + @ColumnNameCreateTable 
+ @AuditColumns 
+ @CRLF +
+ CASE 
	   WHEN @DestinationSchema IN ('fact','bridge') AND @FactIsIncremental = 1 AND @PrimaryKeyColumns IS NOT NULL AND @LoadPattern = 'Standard' THEN 'CONSTRAINT PK_' + @Table + ' PRIMARY KEY NONCLUSTERED (' + @PrimaryKeyColumns + ')'
	   WHEN @DestinationSchema IN ('dim') THEN 'CONSTRAINT NCI_' + @Table + ' UNIQUE NONCLUSTERED (' + @PrimaryDimensionKeyColumns + IIF(@SCD2HistoryFromSourceKey = 1, ',' + @Table + 'ValidFromDate)',',DWValidFromDate)')
 	  -- WHEN @DestinationSchema IN ('dim') AND @SCD2HistoryFromSourceKey = 1 THEN 'CONSTRAINT NCI_' + @Table + ' UNIQUE NONCLUSTERED (' + @PrimaryDimensionKeyColumns + ',' + @Table + 'ValidFromDate)'
	  -- WHEN @DestinationSchema IN ('dim') AND NOT EXISTS (SELECT * FROM @SCD2Columns) THEN 'CONSTRAINT NCI_' + @Table + ' UNIQUE NONCLUSTERED (' + @PrimaryDimensionKeyColumns + ')'
	   ELSE ''
  END +
')'

/*Generates the final create temp table script for incremental facts*/

SET @CreateTempTableScript = 'CREATE TABLE [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].[' + @Table + '_Temp]' + @CRLF +
'(' + @CRLF +
+ @ColumnNameCreateTable
+ @AuditColumns
+ @CRLF +
CASE 
	 WHEN @CompatibilityLevel >= 130  AND @SQLEnterpriseServer = 1 AND @PrimaryKeyColumns IS NOT NULL AND @LoadPattern = 'Standard' AND @FactEngineIsSQLFlag = 0 AND @FactInMemoryFlag = 1 THEN 'INDEX PK_TEMP_' + @Table + ' UNIQUE NONCLUSTERED HASH (' + @PrimaryKeyColumns + ') WITH (BUCKET_COUNT = 1000000)' 
	 WHEN @LoadPattern = 'Standard' AND @PrimaryKeyColumns IS NOT NULL THEN 'CONSTRAINT PK_TEMP_' + @Table + ' PRIMARY KEY NONCLUSTERED (' + @PrimaryKeyColumns + ')' 
	 ELSE ''
END + @CRLF + 
') ' + CASE WHEN @CompatibilityLevel >= 130  AND @SQLEnterpriseServer = 1 AND @PrimaryKeyColumns IS NOT NULL AND @LoadPattern = 'Standard' AND @FactEngineIsSQLFlag = 0 AND @FactInMemoryFlag = 1 THEN ' WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_ONLY)' ELSE '' END

SET @CreateClusteredColumnStoreIndexScript = 'CREATE CLUSTERED COLUMNSTORE INDEX [CCI_' + @Table + '] ON [' + @DatabaseNameDW + '].[fact].[' + @Table + '] WITH (DROP_EXISTING = OFF)'

/*Generates the final create view script*/

SET @PrepareViewScript = 'CREATE VIEW [' + @DestinationSchema + 'View].[' + @ViewName + '] AS' + @CRLF +
'SELECT' + @CRLF +
CASE WHEN @DestinationSchema IN ('dim') THEN' [' + @Table + @SurrogatKeySuffix + ']' + @CRLF + ',' 
     ELSE '' 
END + @ColumnNameCreateView + @CRLF +
'  FROM [' + @DestinationSchema + '].[' + @Table + ']'

END

/*Generates the create view script so it can be executed in the DW database*/
SET @CreateViewScript =IIF(@IsSingleDatabase = 1,'','USE [' + @DatabaseNameDW + ']') + @CRLF + 'EXEC(''' + @PrepareViewScript + ''')'


SET @PrepareTempViewScript = 'CREATE VIEW [' + @DestinationSchema + 'View].[' + @ViewName + '_Temp] AS' + @CRLF +
'SELECT' + @CRLF +
CASE WHEN @DestinationSchema IN ('dim') THEN' [' + @Table + @SurrogatKeySuffix + ']' + @CRLF + ',' 
     ELSE '' 
END + @ColumnNameCreateView + @CRLF +
'  FROM [' + @DestinationSchema + '].[' + @Table + '_Temp]'

SET @CreateTempViewScript =IIF(@IsSingleDatabase = 1,'','USE [' + @DatabaseNameDW + ']') + @CRLF + 'EXEC(''' + @PrepareTempViewScript + ''')'

SET @CreateIncrementalProperty = 'EXEC [' + @DatabaseNameDW + '].sys.sp_addextendedproperty @name=N''IncrementalFactOrBridgeFlag'', @value=N''1'' ,@level0type = N''Schema'', @level0name = ''' + @DestinationSchema + ''' ,@level1type = N''Table'',  @level1name = ''' + @Table + '''' + @CRLF

SET @CreateTruncateProperty = IIF(@TruncateFlag = 0,'','EXEC [' + @DatabaseNameDW + '].sys.sp_addextendedproperty @name = N''TruncateBeforeDeploy'', @value = N''True'', @level0type = N''SCHEMA'', @level0name = N''' + @DestinationSchema + ''', @level1type = N''TABLE'', @level1name = N''' + @Table +'''' + @CRLF	)																						
SET @CreateTruncatePropertyTemp = 'EXEC [' + @DatabaseNameDW + '].sys.sp_addextendedproperty @name = N''TruncateBeforeDeploy'', @value = N''True'', @level0type = N''SCHEMA'', @level0name = N''' + @DestinationSchema + ''', @level1type = N''TABLE'', @level1name = N''' + @Table +'_Temp''' + @CRLF																					

/**********************************************************************************************************************************************************************
10. Execute dynamic SQL
***********************************************************************************************************************************************************************/

IF @PrintSQL = 0

	BEGIN

		/*Check if table exists*/
		IF NOT EXISTS (SELECT * FROM @TableExists)

			BEGIN

				EXEC(@CreateTableScript)
				EXEC(@SCD2) 
				EXEC(@CreateTruncateProperty)
				IF @FactIsIncremental = 1
					BEGIN
						EXEC(@CreateIncrementalProperty)
						EXEC(@PrimaryKeyColumnsExtended) 
					END
				IF @DestinationSchema = 'fact' AND @SQLEnterpriseServer = 1 AND @CompatibilityLevel >= 130 AND @FactCCIFlag = 1
					BEGIN
						EXEC(@CreateClusteredColumnStoreIndexScript)
					END
			END

		/*Check if view exists*/
		IF NOT EXISTS (SELECT * FROM @ViewExists)

			BEGIN
				EXEC(@CreateViewScript)
			END

		/*Check if temp table exists*/

		IF EXISTS (SELECT * FROM @TempTableExists) AND @FactIsIncremental = 1
			BEGIN
				EXEC('DROP TABLE [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].[' + @Table + '_Temp]')
				EXEC(@CreateTempTableScript)
				EXEC(@CreateTruncatePropertyTemp)
			END

		IF NOT EXISTS (SELECT * FROM @TempTableExists) AND @FactIsIncremental = 1

			BEGIN
				EXEC(@CreateTempTableScript)
				EXEC(@CreateTruncatePropertyTemp)
			END

		/*Check if temp view exists*/

		IF NOT EXISTS (SELECT * FROM @TempViewExists) AND @DestinationSchema = 'fact' AND @LoadPattern <> 'Standard' AND @FactIsIncremental = 1

			BEGIN
				EXEC(@CreateTempViewScript)
			END

	END

ELSE

	BEGIN

		 /*Check if table exists*/
		IF NOT EXISTS (SELECT * FROM @TableExists)

			BEGIN

				PRINT(@CreateTableScript) + @CRLF + @CRLF
				PRINT(@SCD2) + @CRLF + @CRLF
				PRINT(@CreateTruncateProperty) + @CRLF + @CRLF
				IF @FactIsIncremental = 1
					BEGIN
						PRINT(@CreateIncrementalProperty) + @CRLF + @CRLF
						PRINT(@PrimaryKeyColumnsExtended) + @CRLF + @CRLF 
					END
				IF @DestinationSchema = 'fact' AND @SQLEnterpriseServer = 1 AND @CompatibilityLevel >= 130 AND @FactCCIFlag = 1
					BEGIN
						PRINT(@CreateClusteredColumnStoreIndexScript) + @CRLF + @CRLF
					END
			END

		/*Check if view exists*/
		IF NOT EXISTS (SELECT * FROM @ViewExists)

			BEGIN
				PRINT(@CreateViewScript) + @CRLF + @CRLF
			END

		/*Check if temp table exists*/

		IF EXISTS (SELECT * FROM @TempTableExists) AND @FactIsIncremental = 1
			BEGIN
				PRINT('DROP TABLE [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].[' + @Table + '_Temp]') + @CRLF + @CRLF
				PRINT(@CreateTempTableScript) + @CRLF + @CRLF
				PRINT(@CreateTruncatePropertyTemp) + @CRLF + @CRLF
			END

		IF NOT EXISTS (SELECT * FROM @TempTableExists) AND @FactIsIncremental = 1

			BEGIN
				PRINT(@CreateTempTableScript) + @CRLF + @CRLF
				PRINT(@CreateTruncatePropertyTemp) + @CRLF + @CRLF
			END

		/*Check if temp view exists*/

		IF NOT EXISTS (SELECT * FROM @TempViewExists) AND @DestinationSchema = 'fact' AND @LoadPattern <> 'Standard' AND @FactIsIncremental = 1

			BEGIN
				PRINT(@CreateTempViewScript) + @CRLF + @CRLF
			END

		


	END

SET NOCOUNT OFF
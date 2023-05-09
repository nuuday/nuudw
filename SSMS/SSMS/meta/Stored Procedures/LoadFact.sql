/**********************************************************************************************************************************************************************
The purpose of this scripts is to create the SQL for fact and bridge loads
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [meta].[LoadFact]
 
@Table NVARCHAR(128),--Input is the fact name without schema
@DestinationSchema NVARCHAR(10),--Input is fact og bridge schema
@LoadPattern NVARCHAR(50),--Input is the load pattern stated in the businessmatrix
@IncrementalFlag BIT, --Input is 1 if the load is incremental and 0 if it is a full load
@CleanUpPartitionsFlag BIT, --Input is 1 if you want to bypass the temp table in order du clean up add partitions in the cube else 0
@DisableMaintainDWFlag BIT, --Input is 1 if you want to bypass MaintainDW else 0. In job the parameter should always be 1
@PrintSQL BIT--Input is 1 if you want to Print the dynamic SQL

AS

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/

DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10)
DECLARE @DatabaseNameStage NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameStage')
DECLARE @DatabaseNameMeta NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameMeta')
DECLARE @DatabaseNameDW NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameDW')
DECLARE @SurrogateKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'SurrogateKeySuffix')
DECLARE @BusinessKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'BusinessKeySuffix')
DECLARE @IncrementalFactTable TABLE (TableName NVARCHAR(128)) 
INSERT @IncrementalFactTable EXEC('SELECT DISTINCT 
											tables.name 
								   FROM 
										[' + @DatabaseNameDW + '].sys.tables 
								   LEFT JOIN 
										[' + @DatabaseNameDW + '].sys.extended_properties AS TableProperties 
											ON TableProperties.major_id = tables.object_id 
								   WHERE 
										tables.name = ''' + @Table + ''' 
										AND TableProperties.name = ''IncrementalFactOrBridgeFlag''')
DECLARE @IncrementalFact BIT = IIF((SELECT * FROM @IncrementalFactTable) IS NOT NULL,@IncrementalFlag,0)
DECLARE @IsIncrementalFact BIT = IIF((SELECT * FROM @IncrementalFactTable) IS NOT NULL,1,0)
DECLARE @FactEngineIsSQLFlag BIT = IIF((SELECT VariableValue FROM meta.Variables WHERE VariableName = 'FactLoadEngine') = 'SQL',1,0)
DECLARE @IsCloudFlag BIT = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'IsCloudFLag')
--DECLARE @StageSchemaTable TABLE (SchemaName NVARCHAR(10)) 
--INSERT @StageSchemaTable-- EXEC('SELECT DISTINCT TABLE_SCHEMA FROM [' + @DatabaseNameStage + '].INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @Table + '''')
DECLARE @StageSchema NVARCHAR(10) = 'stage' --(SELECT IIF(@IsCloudFlag = 1,'stage',(SELECT SchemaName FROM @StageSchemaTable))) --If on-premise and stageschema has not been changed


/**********************************************************************************************************************************************************************
Execute MaintainDW if LoadEngine is SQL
***********************************************************************************************************************************************************************/
IF @IsCloudFlag = 1 AND @DisableMaintainDWFlag = 0
	BEGIN
		EXEC meta.MaintainDW @MasterTable = @Table, @MasterDestinationSchema = @DestinationSchema
		WAITFOR DELAY '00:00:02' --To prevent deadlock when running the procedure in parallel
	END

/**********************************************************************************************************************************************************************
1. Create and insert data into table variables
***********************************************************************************************************************************************************************/

DECLARE @InformationSchema TABLE (DatabaseName NVARCHAR(128),TableName NVARCHAR(128), ColumnName NVARCHAR(128), OrdinalPosition INT, DataType NVARCHAR(128), PrimaryKey INT)
DECLARE @Dimensions TABLE (TableName NVARCHAR(128), DimensionTable NVARCHAR(128), ColumnName NVARCHAR(128),ColumnMapping NVARCHAR(128),RolePlayingDimension NVARCHAR(128),IsSCD2Dimension NVARCHAR(10), IsSCD2CompositeKeyDimension NVARCHAR(10),OrdinalPosition INT,NewDimension NVARCHAR(128), ErrorValue NVARCHAR(128))
DECLARE @SCDCombinedKeys TABLE (DimensionTable NVARCHAR(128), ColumnName NVARCHAR(128), ColumnMapping NVARCHAR(128),OrdinalPosition INT, RolePlayingDimension NVARCHAR(128),NewDimension NVARCHAR(128), ErrorValue NVARCHAR(128))
DECLARE @SCDFromSource TABLE (DimensionTable NVARCHAR(128))
/*Generates the combined information schema*/
INSERT @InformationSchema 
(
 DatabaseName
,TableName
,ColumnName
,OrdinalPosition
,DataType
,PrimaryKey
) 

EXEC('WITH PrimaryKeys AS
								(
									SELECT DISTINCT
										tables.name AS TableName
									   ,all_columns.name AS ColumnName
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
									   AND tables.name = ''' + @Table + '''
									   AND schemas.name = ''' + @DestinationSchema + '''
								)

								SELECT  ''Stage'' AS DatabaseName
										,COLUMNS.TABLE_NAME AS TableName
										,COLUMNS.COLUMN_NAME AS ColumnName
										,COLUMNS.ORDINAL_POSITION
										,COLUMNS.DATA_TYPE AS DataType
										,CASE WHEN PrimaryKeys.ColumnName IS NULL THEN 0 ELSE 1 END AS PrimaryKey
										 
								FROM 
									[' + @DatabaseNameStage + '].INFORMATION_SCHEMA.COLUMNS
								LEFT JOIN 
									PrimaryKeys
										ON PrimaryKeys.ColumnName = COLUMNS.COLUMN_NAME
								WHERE 
									    COLUMNS.TABLE_NAME = ''' + @Table + ''' 
									AND COLUMNS.COLUMN_NAME NOT LIKE ''DW%''
									AND COLUMNS.TABLE_SCHEMA = ''' + @StageSchema + ''''	
								
								)
				
				
/*Generates the mapping dataset between fact/bridge and dimensions*/
INSERT @Dimensions 
(
  TableName
 ,DimensionTable
 ,ColumnName
 ,ColumnMapping
 ,RolePlayingDimension
 ,IsSCD2Dimension
 ,IsSCD2CompositeKeyDimension
 ,OrdinalPosition
 ,NewDimension
 ,ErrorValue
)

EXEC meta.CreateDWRelations @Table = @Table  


SELECT 
	  'DW' AS DatabaseName
	, InformationSchema.TableName
	, ISNULL(Dimensions.RolePlayingDimension + 'ID',InformationSchema.ColumnName) AS ColumnName
	, LEAD(Dimensions.RolePlayingDimension) OVER (PARTITION BY Dimensions.RolePlayingDimension ORDER BY InformationSchema.ColumnName) AS Lead
	, ROW_NUMBER() OVER ( ORDER BY InformationSchema.OrdinalPosition) AS OrdinalPosition
	, IIF(Dimensions.RolePlayingDimension IS NOT NULL,'int',InformationSchema.DataType) AS DataType
	, InformationSchema.PrimaryKey
	INTO #DW
FROM @InformationSchema AS InformationSchema
LEFT JOIN
	@Dimensions AS Dimensions
		ON Dimensions.ColumnName = InformationSchema.ColumnName
GROUP BY InformationSchema.DatabaseName
	, InformationSchema.TableName
	, Dimensions.RolePlayingDimension
	,InformationSchema.ColumnName
	,InformationSchema.OrdinalPosition
	, InformationSchema.DataType
	, InformationSchema.PrimaryKey

INSERT INTO @InformationSchema 
(
 DatabaseName
,TableName
,ColumnName
,OrdinalPosition
,DataType
,PrimaryKey
) 

SELECT DatabaseName, TableName, ColumnName, ROW_NUMBER() OVER ( ORDER BY OrdinalPosition), DataType, PrimaryKey FROM #DW WHERE Lead IS NULL



/*Generates a dataset with composite SCD keys*/
INSERT @SCDCombinedKeys 
(
  DimensionTable
 ,ColumnName
 ,ColumnMapping
 ,OrdinalPosition
 ,RolePlayingDimension
 ,NewDimension
 ,ErrorValue
 )
 
 SELECT Dimensions.DimensionTable
							  ,InformationSchema.ColumnName
							  ,Dimensions.ColumnMapping
							  ,ROW_NUMBER() OVER (ORDER BY CASE WHEN Dimensions.RolePlayingDimension IS NULL THEN Dimensions.DimensionTable 
																			  ELSE Dimensions.RolePlayingDimension 
														   END,InformationSchema.OrdinalPosition) AS ORDINAL_POSITION
							  ,CASE WHEN Dimensions.RolePlayingDimension IS NULL THEN Dimensions.DimensionTable 
									ELSE Dimensions.RolePlayingDimension 
							   END
							  ,CASE WHEN ROW_NUMBER() OVER (PARTITION BY CASE WHEN Dimensions.RolePlayingDimension IS NULL THEN Dimensions.DimensionTable 
																			  ELSE Dimensions.RolePlayingDimension 
																		 END ORDER BY Dimensions.DimensionTable,InformationSchema.OrdinalPosition)  = 1 THEN N'Yes' 
									ELSE N'No' 
							   END 
							  ,Dimensions.ErrorValue
						FROM 
							@InformationSchema AS InformationSchema
						LEFT JOIN 
							@Dimensions AS Dimensions
								ON Dimensions.ColumnName = InformationSchema.ColumnName					
						WHERE 
							Dimensions.IsSCD2Dimension = 'Yes' 
							AND InformationSchema.DatabaseName = 'Stage'

INSERT @SCDFromSource 
(DimensionTable)

EXEC('SELECT DISTINCT TABLE_NAME AS DimensionTable FROM [' + @DatabaseNameStage + '].INFORMATION_SCHEMA.COLUMNS WHERE REPLACE(COLUMN_NAME,TABLE_NAME,'''') IN (''IsCurrent'',''ValidFromDate'',''ValidToDate'') AND TABLE_SCHEMA = ''stage''') 				
			

SELECT Dimensions.TableName
	  ,Dimensions.DimensionTable
	  ,Dimensions.ColumnName
	  ,Dimensions.ColumnMapping
	  ,Dimensions.RolePlayingDimension
	  ,Dimensions.IsSCD2Dimension
	  ,Dimensions.IsSCD2CompositeKeyDimension
	  ,ROW_NUMBER() OVER (ORDER BY InformationSchema.OrdinalPosition, Dimensions.OrdinalPosition) AS OrdinalPosition
	  ,Dimensions.NewDimension
	  ,Dimensions.ErrorValue
INTO #Dimensions
FROM @Dimensions AS Dimensions
INNER JOIN
	@InformationSchema AS InformationSchema
		ON InformationSchema.ColumnName = Dimensions.RolePlayingDimension + 'ID'
		AND InformationSchema.DatabaseName = 'DW'

DELETE FROM @Dimensions

INSERT INTO @Dimensions
(
  TableName
 ,DimensionTable
 ,ColumnName
 ,ColumnMapping
 ,RolePlayingDimension
 ,IsSCD2Dimension
 ,IsSCD2CompositeKeyDimension
 ,OrdinalPosition
 ,NewDimension
 ,ErrorValue
)

SELECT TableName
	  ,DimensionTable
	  ,ColumnName
	  ,ColumnMapping
	  ,RolePlayingDimension
	  ,IsSCD2Dimension
	  ,IsSCD2CompositeKeyDimension
	  ,OrdinalPosition
	  ,NewDimension
	  ,ErrorValue
FROM #Dimensions




/**********************************************************************************************************************************************************************
2. Create Loop counter variables and SCD2FromSource variable
***********************************************************************************************************************************************************************/

DECLARE @Counter INT 
DECLARE @MaxColumns INT  --Number of columns from stage
DECLARE @MaxSCDJoinColumns INT --Max position of composite SCD2 key columns
DECLARE @MaxJoinColumns INT --Max position of key columns from fact/bridge
DECLARE @MaxColumnsKeys INT --Max position of primary key columns i fact/bridge
DECLARE @MaxColumnsFact INT --Number of columns in fact/bridge

SELECT 
	   @Counter = 1
	  ,@MaxColumns = (SELECT MAX(OrdinalPosition) FROM @InformationSchema WHERE DatabaseName = 'Stage' )
	  ,@MaxJoinColumns = (SELECT MAX(OrdinalPosition) FROM @Dimensions) 
	  ,@MaxSCDJoinColumns = (SELECT MAX(OrdinalPosition) FROM @SCDCombinedKeys) 
	  ,@MaxColumnsKeys = (SELECT MAX(OrdinalPosition) FROM @InformationSchema WHERE PrimaryKey = 1 AND DatabaseName = 'DW')
	  ,@MaxColumnsFact = (SELECT MAX(OrdinalPosition) FROM @InformationSchema WHERE DatabaseName = 'DW')
	 
/**********************************************************************************************************************************************************************
3. Create position and support variables
***********************************************************************************************************************************************************************/

DECLARE @HasCalendarKey INT 
DECLARE @PositionFirstNonSCDColumn INT
DECLARE @SCDExists INT --Min position of key column from stage which is not an SCD column

SELECT
	   @HasCalendarKey = CASE WHEN (SELECT COUNT(*) FROM @InformationSchema WHERE ColumnName = 'Calendar' + @BusinessKeySuffix) > 0 THEN 1 ELSE 0 END --Check if CalendarKey is present
	  ,@PositionFirstNonSCDColumn = (SELECT MIN(I.OrdinalPosition) FROM @InformationSchema I INNER JOIN @Dimensions D ON D.ColumnName = I.ColumnName WHERE IsSCD2Dimension = 'No') --Gives the position of the first non SCD column
	  ,@SCDExists = IIF(EXISTS((SELECT * FROM @SCDCombinedKeys)),1,0)

/**********************************************************************************************************************************************************************
4. Create the select part of the source code for SCD dimensions
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderSelectSCD NVARCHAR(MAX)
DECLARE @SelectSCD NVARCHAR(MAX)

WHILE @Counter <= @MaxColumns

BEGIN

	SELECT @PlaceholderSelectSCD = --Check if it is the first column
								   CASE 
										WHEN @Counter = @PositionFirstNonSCDColumn 
											THEN ' '
										ELSE ','
								   END
								   
								   +
								   
								   --SCD2Composite keys is handled seperatly. Char columns is UPPER cased and date columns is cast to datetime
								   CASE 
										WHEN IsSCD2CompositeKeyDimension = 'Yes' 
											THEN CASE 
													WHEN InformationSchema.DataType LIKE '%char%' 
														THEN  'UPPER([' + InformationSchema.TableName + '].[' + InformationSchema.ColumnName + ']) AS [' + InformationSchema.ColumnName + ']'
													WHEN InformationSchema.DataType LIKE '%date%' 
														THEN  'CAST([' + InformationSchema.TableName + '].[' + InformationSchema.ColumnName + '] AS DATETIME) AS [' + InformationSchema.ColumnName + ']'
													ELSE '[' + InformationSchema.TableName + '].[' + InformationSchema.ColumnName + ']' 
												 END
										ELSE CASE 
												WHEN InformationSchema.DataType LIKE '%char%' 
													THEN  'UPPER([' + InformationSchema.ColumnName + ']) AS [' + InformationSchema.ColumnName + ']'
												WHEN InformationSchema.DataType LIKE '%date%' 
													THEN  'CAST([' + InformationSchema.ColumnName + '] AS DATETIME) AS [' + InformationSchema.ColumnName + ']'
												ELSE '[' + InformationSchema.ColumnName + ']' 
											 END
									END

								   + 
								   
								   @CRLF
	FROM 
		@InformationSchema AS InformationSchema
	LEFT JOIN 
		@Dimensions AS Dimensions
			ON Dimensions.ColumnName = InformationSchema.ColumnName
	WHERE 
		    Dimensions.IsSCD2Dimension = 'No' 
		AND @Counter = InformationSchema.OrdinalPosition 
		AND InformationSchema.DatabaseName = 'Stage'


	SET @SelectSCD = CONCAT(@SelectSCD,@PlaceholderSelectSCD)

	SET @PlaceholderSelectSCD = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
5. Create the select part of the source code for non ID columns
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderSelect NVARCHAR(MAX) = ''
DECLARE @Select NVARCHAR(MAX) = ''


WHILE @Counter <= @MaxColumns

BEGIN

	SELECT @PlaceholderSelect = ', [' + @Table + '].[' + InformationSchema.ColumnName + ']' + @CRLF
	FROM 
		@InformationSchema AS InformationSchema
	LEFT JOIN 
		@Dimensions AS Dimensions
			ON Dimensions.ColumnName = InformationSchema.ColumnName
	WHERE 
		Dimensions.DimensionTable IS NULL 
		AND @Counter = InformationSchema.OrdinalPosition 
		AND InformationSchema.DatabaseName = 'Stage'

	SET @Select = CONCAT(@Select,@PlaceholderSelect)

	SET @PlaceholderSelect = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1



/**********************************************************************************************************************************************************************
6. Create the select SCD ID with error handling 
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderIDSCDMerge NVARCHAR(MAX) 
DECLARE @IDSCDMerge NVARCHAR(MAX)
DECLARE @PlaceholderIDSCDColumns NVARCHAR(MAX) 
DECLARE @IDSCDColumns NVARCHAR(MAX)
DECLARE @PlaceholderIDSCD NVARCHAR(MAX)
DECLARE @IDSCD NVARCHAR(MAX)

WHILE @Counter <= @MaxSCDJoinColumns	

BEGIN

	SELECT @PlaceholderIDSCDMerge = CASE 
									WHEN @Counter = @SCDExists 
										THEN '' 
									ELSE ',' 
									END 
				 
									+ 
								
									'ISNULL([' + RolePlayingDimension + '].[' + DimensionTable + @SurrogateKeySuffix + '],' + ErrorValue +') AS [' + RolePlayingDimension + @SurrogateKeySuffix + ']' + @CRLF	
		, @PlaceholderIDSCDColumns = CASE 
									WHEN @Counter = @SCDExists 
										THEN '' 
									ELSE ',' 
									END 
									+ '[' + RolePlayingDimension + @SurrogateKeySuffix + ']' + @CRLF
		, @PlaceholderIDSCD = ',[' + RolePlayingDimension + '].[' + DimensionTable + @SurrogateKeySuffix + ']' + CASE 
																								WHEN RolePlayingDimension <> DimensionTable 
																									THEN ' AS [' + RolePlayingDimension + @SurrogateKeySuffix + ']'
	  																							ELSE '' 
																							END + @CRLF
	FROM 
		@SCDCombinedKeys
	WHERE 
			@Counter = OrdinalPosition 
		AND NewDimension = 'Yes' 
    
	SET @IDSCDMerge = CONCAT(@IDSCDMerge,@PlaceholderIDSCDMerge)
	
	SET @IDSCDColumns = CONCAT(@IDSCDColumns,@PlaceholderIDSCDColumns)

	SET @IDSCD = CONCAT(@IDSCD,@PlaceholderIDSCD)

	SET @PlaceholderIDSCD = ''

	SET @PlaceholderIDSCDMerge = ''

	SET @PlaceholderIDSCDColumns = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1



/**********************************************************************************************************************************************************************
7. Create the select ID part for source code 
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderIDMerge NVARCHAR(MAX)
DECLARE @IDMerge NVARCHAR(MAX) 

WHILE @Counter <= @MaxJoinColumns

BEGIN

	SELECT 
		  @PlaceholderIDMerge = CASE 
									WHEN @SCDExists = 0 AND @Counter = 1 
										THEN '' 
									ELSE ',' 
									END 
				 
									+ 
								CASE 
									WHEN RolePlayingDimension IS NOT NULL 
										THEN 'ISNULL([' + RolePlayingDimension + '].[' + DimensionTable + @SurrogateKeySuffix + '],' + ErrorValue + ') AS [' + RolePlayingDimension + @SurrogateKeySuffix + ']'
									ELSE 'ISNULL([' + DimensionTable + '].[' + DimensionTable + @SurrogateKeySuffix + '],' + ErrorValue + ') AS ' + '[' + DimensionTable + @SurrogateKeySuffix + ']' 
								END  
				 	 
								+ @CRLF
	FROM 
		@Dimensions
	WHERE
			@Counter = OrdinalPosition 
		AND NewDimension = 'Yes' 
		AND IsSCD2Dimension = 'No'

	SET @IDMerge = CONCAT(@IDMerge,CASE WHEN ISNULL( CHARINDEX (REPLACE(@PlaceholderIDMerge,',','') , @IDMerge),0) <> 0 THEN '' ELSE @PlaceholderIDMerge END)

	SET @PlaceholderIDMerge = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1


/**********************************************************************************************************************************************************************
8. Create the the left join part for SCD dimensions
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderLeftJoinSCD NVARCHAR(MAX) 
DECLARE @LeftJoinSCD NVARCHAR(MAX) 

WHILE @Counter <= @MaxSCDJoinColumns

BEGIN

	SELECT @PlaceholderLeftJoinSCD = CASE
										WHEN NewDimension = 'Yes'
											THEN 'LEFT JOIN [' + @DatabaseNameDW + '].[dim].[' + SCDCombinedKeys.DimensionTable + '] ' + CASE 
																																			WHEN RolePlayingDimension IS NOT NULL 
																																				THEN ' AS [' + RolePlayingDimension + ']' 
																																			ELSE '' 
																																		 END + @CRLF + 'ON  ' + CASE 
																																									WHEN @HasCalendarKey = 1 AND SCDFromSource.DimensionTable IS NULL
																																										THEN '[' + @Table + '].[CalendarKey] BETWEEN [' + RolePlayingDimension + '].[DWValidFromDate] AND [' + RolePlayingDimension + '].[DWValidToDate]' 
																																									WHEN @HasCalendarKey = 1 AND SCDFromSource.DimensionTable IS NOT NULL
																																										THEN '[' +  @Table + '].[CalendarKey] BETWEEN [' + RolePlayingDimension + '].[' + SCDFromSource.DimensionTable + 'ValidFromDate] AND [' + RolePlayingDimension + '].[' + SCDFromSource.DimensionTable + 'ValidToDate]' 
																																									WHEN @HasCalendarKey = 0 AND SCDFromSource.DimensionTable IS NOT NULL
																																										THEN  '[' + RolePlayingDimension + '].[' + SCDFromSource.DimensionTable + 'IsCurrent] = 1 ' 
																																									ELSE  '[' + RolePlayingDimension + '].[DWIsCurrent] = 1 ' 
																																								 END +  @CRLF + 'AND [' + RolePlayingDimension + '].[' + ColumnMapping  + '] = [' + @Table + '].[' + ColumnName + ']' 
										ELSE 'AND [' + RolePlayingDimension + '].[' + ColumnMapping + '] = [' + @Table + '].[' + ColumnName + ']' 
									 END + @CRLF
	FROM
		@SCDCombinedKeys AS SCDCombinedKeys
	LEFT JOIN 
		@SCDFromSource AS SCDFromSource
			ON SCDFromSource.DimensionTable = SCDCombinedKeys.DimensionTable
	WHERE 
		@Counter = OrdinalPosition
	
	SET @LeftJoinSCD = CONCAT(@LeftJoinSCD,@PlaceholderLeftJoinSCD)

	SET @PlaceholderLeftJoinSCD = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
9. Create the left join part for non SCD dimensions
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderLeftJoin NVARCHAR(MAX)
DECLARE @LeftJoin NVARCHAR(MAX)

WHILE @Counter <= @MaxJoinColumns

BEGIN

	SELECT @PlaceholderLeftJoin = CASE 
										WHEN NewDimension = 'Yes'
											THEN 'LEFT JOIN [' + @DatabaseNameDW + '].[dim].[' + DimensionTable + '] ' + CASE 
																																WHEN RolePlayingDimension IS NOT NULL 
																																	THEN ' AS [' + RolePlayingDimension + ']' 
																																ELSE '' 
																														   END + @CRLF + 'ON [' + CASE 
																																					WHEN RolePlayingDimension IS NOT NULL 
																																						THEN RolePlayingDimension 
																																					ELSE DimensionTable 
																																				 END + '].[' + ColumnMapping  + '] = [' + @Table + '].[' + ColumnName + ']' 
										ELSE 'AND [' + CASE 
														 WHEN RolePlayingDimension IS NOT NULL 
															THEN RolePlayingDimension 
													     ELSE DimensionTable 
													  END + '].[' + ColumnMapping + '] = [' + @Table + '].[' + ColumnName + ']' 
								  END + @CRLF
	FROM 
		@Dimensions
	WHERE 
			@Counter = OrdinalPosition 
		AND IsSCD2Dimension = 'No'

	SET @LeftJoin = CONCAT(@LeftJoin,@PlaceholderLeftJoin)

	SET @PlaceholderLeftJoin = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
10. Create the key part of the merge join statement
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderKeys NVARCHAR(MAX) --Placeholder used in the loop generating the business keys used in the Merge Join script
DECLARE @Keys NVARCHAR(MAX) --Holds the value of @Keys for each loop

WHILE @Counter <= @MaxColumnsKeys

BEGIN

	SELECT @PlaceholderKeys = '[source].[' + ColumnName + '] = [target].[' + ColumnName + ']'  + CASE 
																									WHEN @Counter != @MaxColumnsKeys 
																										THEN ' AND ' 
																								    ELSE '' 
																								 END
	FROM 
		@InformationSchema 
	WHERE 
			PrimaryKey = 1 
		AND OrdinalPosition = @Counter 
		AND DatabaseName = 'DW'

	SET @Keys = CONCAT(@Keys,@PlaceholderKeys)

	SET @PlaceholderKeys = ''

	SET @Counter = @Counter + 1

END


SET @Counter = 1
	
/**********************************************************************************************************************************************************************
11. Create the columns from stage for the merge script
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderColumnNameFact NVARCHAR(MAX) --Placeholder for the match SCD1 part of the script
DECLARE @ColumnNameFact NVARCHAR(MAX) --Holds the value of @ColumnNameDim for each loop

WHILE @Counter <= @MaxColumnsFact

BEGIN 

	SELECT @PlaceholderColumnNameFact = ',[' + InformationSchema.ColumnName + ']' + @CRLF

	FROM 
		@InformationSchema AS InformationSchema	
	WHERE 
			InformationSchema.OrdinalPosition = @Counter 
		AND DatabaseName = 'DW'
		AND InformationSchema.ColumnName NOT LIKE '%ID'

	SET @ColumnNameFact = CONCAT(@ColumnNameFact,@PlaceholderColumnNameFact)

	SET @PlaceholderColumnNameFact = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
11. Create the columns from stage for the merge script
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderColumnNameIDFact NVARCHAR(MAX) --Placeholder for the match SCD1 part of the script
DECLARE @ColumnNameIDFact NVARCHAR(MAX) --Holds the value of @ColumnNameDim for each loop
DECLARE @FirstKey INT = (SELECT MIN(InformationSchema.OrdinalPosition) FROM @InformationSchema AS InformationSchema LEFT JOIN (SELECT RolePlayingDimension,SUM(OrdinalPosition) AS OrdinalPosition FROM @SCDCombinedKeys GROUP BY RolePlayingDimension) AS SCDColumns ON CONCAT(SCDColumns.RolePlayingDimension,'ID') = InformationSchema.ColumnName WHERE DatabaseName = 'DW'AND SCDColumns.RolePlayingDimension IS NULL AND InformationSchema.ColumnName LIKE '%ID')

WHILE @Counter <= @MaxColumnsFact

BEGIN 

	SELECT @PlaceholderColumnNameIDFact = CASE 
										WHEN @SCDExists = 0 AND @Counter = @FirstKey 
											THEN '' 
										ELSE ',' 
									END 	 

									+ '[' + InformationSchema.ColumnName + ']' + @CRLF

	FROM 
		@InformationSchema AS InformationSchema
	LEFT JOIN
		(SELECT RolePlayingDimension,SUM(OrdinalPosition) AS OrdinalPosition FROM @SCDCombinedKeys GROUP BY RolePlayingDimension) AS SCDColumns
			ON CONCAT(SCDColumns.RolePlayingDimension,'ID') = InformationSchema.ColumnName
	WHERE 
			InformationSchema.OrdinalPosition = @Counter 
		AND DatabaseName = 'DW'
		AND SCDColumns.RolePlayingDimension IS NULL
		AND InformationSchema.ColumnName LIKE '%ID'

	SET @ColumnNameIDFact = CONCAT(@ColumnNameIDFact,@PlaceholderColumnNameIDFact)

	SET @PlaceholderColumnNameIDFact = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1



/**********************************************************************************************************************************************************************
12. Create the match part and the update part for the merge script
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderUpdateSCD1 NVARCHAR(MAX) --Placeholder for the update SCD1 part of the script
DECLARE @UpdateSCD1 NVARCHAR(MAX) --Holds the value of @ColumnNameDim for each loop
DECLARE @PlaceholderMatchSCD1 NVARCHAR(MAX) --Placeholder for the match SCD1 part of the script
DECLARE @MatchSCD1 NVARCHAR(MAX) --Holds the value of @ColumnNameDim for each loop

WHILE @Counter <= @MaxColumnsFact

BEGIN 

	SELECT @PlaceholderMatchSCD1 =  '([target].[' + ColumnName + '] <> [source].[' + ColumnName + ']) OR ([target].[' + ColumnName + '] IS NULL AND [source].[' + ColumnName + '] IS NOT NULL) OR ([target].[' + ColumnName + '] IS NOT NULL AND [source].[' + ColumnName + '] IS NULL)' 
									+ CASE 
										  WHEN @Counter != @MaxColumnsFact 
											 THEN ' OR ' 
										  ELSE '' 
									  END + @CRLF 
		  ,@PlaceholderUpdateSCD1 = '[target].[' + ColumnName + '] = [source].[' + ColumnName + '],' + @CRLF
        
	FROM 
		@InformationSchema
	WHERE 
			OrdinalPosition = @Counter 
		AND DatabaseName = 'DW'

	SET @MatchSCD1 = CONCAT(@MatchSCD1,@PlaceholderMatchSCD1)

	SET @PlaceholderMatchSCD1 = ''

	SET @UpdateSCD1 = CONCAT(@UpdateSCD1,@PlaceholderUpdateSCD1)

	SET @PlaceholderUpdateSCD1 = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
13. Create the delta part of the source code
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderSelectDelta NVARCHAR(MAX) = ''
DECLARE @SelectDelta NVARCHAR(MAX) = ''

WHILE @Counter <= @MaxColumns

BEGIN

	SELECT @PlaceholderSelectDelta  = IIF(@Counter = 1,'',',') + CASE 
																	WHEN ColumnName NOT LIKE '%ID' AND ColumnName NOT LIKE '%Code' AND ColumnName NOT LIKE '%Number' AND Datatype IN ('Decimal','Numeric','int','bigint') THEN '-'
																	ELSE ''
																 END + '[target].[' + InformationSchema.ColumnName + ']' + @CRLF
	FROM 
		@InformationSchema AS InformationSchema	
	WHERE 
		@Counter = InformationSchema.OrdinalPosition 
		AND InformationSchema.DatabaseName = 'DW'
		AND InformationSchema.ColumnName <> 'LastValueLoaded'

	SET @SelectDelta = CONCAT(@SelectDelta,@PlaceholderSelectDelta)

	SET @PlaceholderSelectDelta = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1


/**********************************************************************************************************************************************************************
14. Fill out dynamic SQL variables
***********************************************************************************************************************************************************************/

DECLARE @DeleteFromFact NVARCHAR(MAX) --Holds the SCD1 part of the Merge Join Script
DECLARE @SQLFullLoad NVARCHAR(MAX) --Holds the SCD1 part of the Merge Join Script
DECLARE @SQLDelta NVARCHAR(MAX)
DECLARE @SQLReplacement NVARCHAR(MAX)
DECLARE @SQLStandard NVARCHAR(MAX)
DECLARE @SQLAdd NVARCHAR(MAX)
DECLARE @SQLMergeJoin NVARCHAR(MAX) --Holds the SCD1 part of the Merge Join Script
DECLARE @SQL NVARCHAR(MAX) --Holds the SCD1 part of the Merge Join Script

SET @SQLMergeJoin =
IIF(@IsCloudFlag = 1 ,'','USE ' + @DatabaseNameDW) + @CRLF + @CRLF +
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

-- ==================================================
-- SCD1
-- ==================================================

MERGE [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].['+ @Table + '] as [target] USING
	  [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].[' + @Table + '_Temp] as [source]

-- Selects source rows in order to compare them to [target]

ON
(
' + @Keys + '
)

WHEN NOT MATCHED BY TARGET THEN

INSERT 
(
' 
+ ISNULL(@IDSCDColumns,'') +
+ ISNULL(@ColumnNameIDFact,'') +
+ ISNULL(@ColumnNameFact,'') + 
',[DWCreatedDate]
,[DWModifiedDate]

)

VALUES 
(
'  
+ ISNULL(@IDSCDColumns,'') +
+ ISNULL(@ColumnNameIDFact,'') +
+ ISNULL(@ColumnNameFact,'') + 
',@CurrentDateTime
,@CurrentDateTime
)


WHEN MATCHED 

THEN UPDATE

SET 
'+  @UpdateSCD1 + '[target].[DWModifiedDate] = @CurrentDateTime

;'

SET @SQLFullLoad = 'TRUNCATE TABLE [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].['+ @Table + '] ' 
+ IIF(@IsIncrementalFact = 1,'TRUNCATE TABLE [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].['+ @Table + '_Temp]','') + '  

EXEC [' + @DatabaseNameMeta + '].meta.[MaintainDWFactIndexes] @Table = ''' + @Table + ''', @DestinationSchema = ''' + @DestinationSchema + ''',@DisableIndexes = 1, @PrintSQL = 0
 
DECLARE @UpdateDateTime datetime = GETDATE()

INSERT INTO [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].['+ @Table + '] WITH (TABLOCK)
(
'   + ISNULL(@IDSCDColumns,'') 
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	,DWCreatedDate
	,DWModifiedDate
)  

SELECT 
	' + ISNULL(@IDSCDMerge,'')
	  + ISNULL(@IDMerge,'')
	  + ISNULL(@Select ,'')
	  + ',@UpdateDateTime' + @CRLF + ',@UpdateDateTime
FROM [' + @DatabaseNameStage + '].[' + @StageSchema + '].['+ @Table + '] AS ' + @Table + ' ' + @CRLF +
ISNULL(@LeftJoinSCD,'') + 
ISNULL(@LeftJoin,'') + @CRLF + @CRLF +

'EXEC [' + @DatabaseNameMeta + '].meta.[MaintainDWFactIndexes] @Table = ''' + @Table + ''', @DestinationSchema = ''' + @DestinationSchema + ''', @DisableIndexes = 0, @PrintSQL = 0'

SET @SQLStandard = 'TRUNCATE TABLE [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].['+ @Table + '_Temp] 

DECLARE @UpdateDateTime datetime = GETDATE()

INSERT INTO [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].['+ @Table + '_Temp] WITH (TABLOCK)
(
'   + ISNULL(@IDSCDColumns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	,DWCreatedDate
	,DWModifiedDate
)  

SELECT 
	' + ISNULL(@IDSCDMerge,'')
	  + ISNULL(@IDMerge,'')
	  + ISNULL(@Select ,'')
	  + ', @UpdateDateTime AS DWCreatedDate ' + @CRLF + ', @UpdateDateTime AS DWModifiedDate
FROM [' + @DatabaseNameStage + '].[' + @StageSchema + '].['+ @Table + '] AS ' + @Table + ' ' + @CRLF +
ISNULL(@LeftJoinSCD,'') + 
ISNULL(@LeftJoin,'') + @CRLF + @CRLF 

SET @SQLAdd = 'TRUNCATE TABLE [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].['+ @Table + '_Temp] 

BEGIN TRY
    BEGIN TRAN

DECLARE @UpdateDateTime datetime = GETDATE()

DROP TABLE IF EXISTS #TempRows

SELECT 
	' + ISNULL(@IDSCDMerge,'')
	  + ISNULL(@IDMerge,'')
	  + ISNULL(@Select ,'')
	  + ', @UpdateDateTime AS DWCreatedDate' + @CRLF + ', @UpdateDateTime AS DWModifiedDate
	  INTO 
		#TempRows
FROM [' + @DatabaseNameStage + '].[' + @StageSchema + '].['+ @Table + '] AS ' + @Table + ' ' + @CRLF +
ISNULL(@LeftJoinSCD,'') + 
ISNULL(@LeftJoin,'') + @CRLF + @CRLF +

'INSERT INTO [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].['+ @Table + '] WITH (TABLOCK)
(
'   + ISNULL(@IDSCDColumns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	,DWCreatedDate
	,DWModifiedDate
)  

SELECT 
	'  + ISNULL(@IDSCDColumns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	,DWCreatedDate
	,DWModifiedDate
FROM #TempRows ' + @CRLF + @CRLF +

IIF(@CleanUpPartitionsFlag = 0,
'INSERT INTO [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].['+ @Table + '_Temp] WITH (TABLOCK)
(
'   + ISNULL(@IDSCDColumns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	,DWCreatedDate
	,DWModifiedDate
)  

SELECT 
	'  + ISNULL(@IDSCDColumns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	,DWCreatedDate
	,DWModifiedDate
FROM #TempRows '
,'') + @CRLF + @CRLF +

'COMMIT TRAN
END TRY
BEGIN CATCH
		IF @@TRANCOUNT > 0		
			ROLLBACK TRAN; --RollBack in case of Error
		THROW;  
END CATCH'


SET @DeleteFromFact = '
DELETE [target] WITH (TABLOCK)
FROM
	[' + @DatabaseNameDW + '].[' + @DestinationSchema + '].['+ @Table + '] AS [target]'  + @CRLF +
'INNER JOIN
	[' + @DatabaseNameStage + '].[' + @StageSchema + '].['+ @Table + '] AS [source]' + @CRLF + 'ON ' +
	+ @Keys



SET @SQLDelta = 'TRUNCATE TABLE [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].['+ @Table + '_Temp] ' + @CRLF + @CRLF +

'BEGIN TRY
    BEGIN TRAN' + @CRLF + @CRLF +
		
IIF(@CleanUpPartitionsFlag = 0,' EXEC [' + @DatabaseNameMeta + '].meta.FactPatternsDelta @Table = ''' + @Table + ''', @DestinationSchema = ''' + @DestinationSchema + ''', @CleanUpPartitionsFlag = 0, @PrintSQL = 0','')  + @CRLF +
IIF(@CleanUpPartitionsFlag = 1,@DeleteFromFact,'') + @CRLF + @CRLF +  

'
DECLARE @UpdateDateTime datetime = GETDATE()

DROP TABLE IF EXISTS #TempRows

SELECT 
	' + ISNULL(@IDSCDMerge,'')
	  + ISNULL(@IDMerge,'')
	  + ISNULL(@Select ,'')
	  + ', @UpdateDateTime AS DWCreatedDate' + @CRLF + ', @UpdateDateTime AS DWModifiedDate
	  INTO 
		#TempRows
FROM [' + @DatabaseNameStage + '].[' + @StageSchema + '].['+ @Table + '] AS ' + @Table + ' ' + @CRLF +
ISNULL(@LeftJoinSCD,'') + 
ISNULL(@LeftJoin,'') + @CRLF + @CRLF +

'INSERT INTO [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].['+ @Table + '] WITH (TABLOCK)
(
'   + ISNULL(@IDSCDColumns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	,DWCreatedDate
	,DWModifiedDate
)  

SELECT 
	'  + ISNULL(@IDSCDColumns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	,DWCreatedDate
	,DWModifiedDate
FROM #TempRows ' + @CRLF + @CRLF +

IIF(@CleanUpPartitionsFlag = 0,
'INSERT INTO [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].['+ @Table + '_Temp] WITH (TABLOCK)
(
'   + ISNULL(@IDSCDColumns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	,DWCreatedDate
	,DWModifiedDate
)  

SELECT 
	'  + ISNULL(@IDSCDColumns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	,DWCreatedDate
	,DWModifiedDate
FROM #TempRows '
,'') + @CRLF + @CRLF +

'COMMIT TRAN
END TRY
BEGIN CATCH
		IF @@TRANCOUNT > 0		
			ROLLBACK TRAN; --RollBack in case of Error
		THROW;  
END CATCH'

SET @SQLReplacement = 'TRUNCATE TABLE [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].['+ @Table + '_Temp] ' + @CRLF + @CRLF +

'BEGIN TRY
    BEGIN TRAN' + @CRLF + @CRLF +
		
IIF(@CleanUpPartitionsFlag = 0,' EXEC [' + @DatabaseNameMeta + '].meta.FactPatternsReplacement @Table = ''' + @Table + ''', @DestinationSchema = ''' + @DestinationSchema + ''', @CleanUpPartitionsFlag = 0, @PrintSQL = 0','')  + @CRLF +
IIF(@CleanUpPartitionsFlag = 1,' EXEC [' + @DatabaseNameMeta + '].meta.FactPatternsReplacement @Table = ''' + @Table + ''', @DestinationSchema = ''' + @DestinationSchema + ''', @CleanUpPartitionsFlag = 1, @PrintSQL = 0','') + @CRLF + @CRLF +  

'DECLARE @UpdateDateTime datetime = GETDATE()

DROP TABLE IF EXISTS #TempRows

SELECT 
	' + ISNULL(@IDSCDMerge,'')
	  + ISNULL(@IDMerge,'')
	  + ISNULL(@Select ,'')
	  + ', @UpdateDateTime AS DWCreatedDate' + @CRLF + ', @UpdateDateTime AS DWModifiedDate
	  INTO 
		#TempRows
FROM [' + @DatabaseNameStage + '].[' + @StageSchema + '].['+ @Table + '] AS ' + @Table + ' ' + @CRLF +
ISNULL(@LeftJoinSCD,'') + 
ISNULL(@LeftJoin,'') + @CRLF + @CRLF +

'
INSERT INTO [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].['+ @Table + '] WITH (TABLOCK)
(
'   + ISNULL(@IDSCDColumns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	,DWCreatedDate
	,DWModifiedDate
)  

SELECT 
	' + ISNULL(@IDSCDColumns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	,DWCreatedDate
	,DWModifiedDate
FROM #TempRows ' + @CRLF + @CRLF +

IIF(@CleanUpPartitionsFlag = 0,
'INSERT INTO [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].['+ @Table + '_Temp] WITH (TABLOCK)
(
'   + ISNULL(@IDSCDColumns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	,DWCreatedDate
	,DWModifiedDate
)  


SELECT 
	'  + ISNULL(@IDSCDColumns,'') +
	+ ISNULL(@ColumnNameIDFact,'') 
	+ ISNULL(@ColumnNameFact,'') + '
	,DWCreatedDate
	,DWModifiedDate
FROM #TempRows '
,'') + @CRLF + @CRLF +

'COMMIT TRAN
END TRY
BEGIN CATCH
		IF @@TRANCOUNT > 0		
			ROLLBACK TRAN; --RollBack in case of Error
		THROW;  
END CATCH'

SET @SQL = CASE 
				WHEN @IncrementalFact = 0 AND @FactEngineIsSQLFlag = 1 THEN @SQLFullLoad
				WHEN @IncrementalFact = 1 AND @LoadPattern = 'Standard' AND @FactEngineIsSQLFlag = 0 THEN @SQLMergeJoin
				WHEN @IncrementalFact = 1 AND @LoadPattern = 'Standard' AND @FactEngineIsSQLFlag = 1 THEN CONCAT(@SQLStandard,@SQLMergeJoin)
				WHEN @IncrementalFact = 1 AND @LoadPattern = 'Add' AND @FactEngineIsSQLFlag = 1 THEN  @SQLAdd
				WHEN @IncrementalFact = 1 AND @LoadPattern = 'Delta' AND @FactEngineIsSQLFlag = 1 THEN  @SQLDelta
				WHEN @IncrementalFact = 1 AND @LoadPattern = 'Replacement' AND @FactEngineIsSQLFlag = 1 THEN  @SQLReplacement
		   END
		   
IF @PrintSQL = 0

	BEGIN
		
		EXEC(@SQL)

	END

ELSE

	BEGIN
		
		IF @IncrementalFact = 0 AND @FactEngineIsSQLFlag = 1 
			BEGIN 
				PRINT(LEFT(@SQLFullLoad,4000)) 
				PRINT(SUBSTRING(@SQLFullLoad,4001,8000)) 
				PRINT(SUBSTRING(@SQLFullLoad,8001,12000)) 
				PRINT(SUBSTRING(@SQLFullLoad,12001,16000)) 
				PRINT(SUBSTRING(@SQLFullLoad,16001,20000)) 
				PRINT(SUBSTRING(@SQLFullLoad,20001,24000)) 
				PRINT(SUBSTRING(@SQLFullLoad,24001,28000)) 
			END
		IF @IncrementalFact = 1 AND @LoadPattern = 'Standard' AND @FactEngineIsSQLFlag = 0 
			BEGIN
				PRINT(LEFT(@SQLMergeJoin,4000)) 
				PRINT(SUBSTRING(@SQLMergeJoin,4001,8000)) 
				PRINT(SUBSTRING(@SQLMergeJoin,8001,12000)) 
				PRINT(SUBSTRING(@SQLMergeJoin,12001,16000)) 
				PRINT(SUBSTRING(@SQLMergeJoin,16001,20000)) 
				PRINT(SUBSTRING(@SQLMergeJoin,20001,24000)) 
				PRINT(SUBSTRING(@SQLMergeJoin,24001,28000)) 
			END
		IF @IncrementalFact = 1 AND @LoadPattern = 'Standard' AND @FactEngineIsSQLFlag = 1 
			BEGIN
				PRINT(LEFT(@SQLStandard,4000)) 
				PRINT(SUBSTRING(@SQLStandard,4001,8000)) 
				PRINT(SUBSTRING(@SQLStandard,8001,12000)) 
				PRINT(SUBSTRING(@SQLStandard,12001,16000)) 
				PRINT(SUBSTRING(@SQLStandard,16001,20000)) 
				PRINT(SUBSTRING(@SQLStandard,20001,24000)) 
				PRINT(SUBSTRING(@SQLStandard,24001,28000)) 
				PRINT(LEFT(@SQLMergeJoin,4000)) 
				PRINT(SUBSTRING(@SQLMergeJoin,4001,8000)) 
				PRINT(SUBSTRING(@SQLMergeJoin,8001,12000)) 
				PRINT(SUBSTRING(@SQLMergeJoin,12001,16000)) 
				PRINT(SUBSTRING(@SQLMergeJoin,16001,20000)) 
				PRINT(SUBSTRING(@SQLMergeJoin,20001,24000)) 
				PRINT(SUBSTRING(@SQLMergeJoin,24001,28000)) 
			END
		IF @IncrementalFact = 1 AND @LoadPattern = 'Add' AND @FactEngineIsSQLFlag = 1 
			BEGIN
				PRINT(LEFT(@SQLAdd,4000)) 
				PRINT(SUBSTRING(@SQLAdd,4001,8000)) 
				PRINT(SUBSTRING(@SQLAdd,8001,12000)) 
				PRINT(SUBSTRING(@SQLAdd,12001,16000)) 
				PRINT(SUBSTRING(@SQLAdd,16001,20000)) 
				PRINT(SUBSTRING(@SQLAdd,20001,24000)) 
				PRINT(SUBSTRING(@SQLAdd,24001,28000)) 
			END
		IF @IncrementalFact = 1 AND @LoadPattern = 'Delta' AND @FactEngineIsSQLFlag = 1 
			BEGIN
				PRINT(LEFT(@SQLDelta,4000)) 
				PRINT(SUBSTRING(@SQLDelta,4001,8000)) 
				PRINT(SUBSTRING(@SQLDelta,8001,12000)) 
				PRINT(SUBSTRING(@SQLDelta,12001,16000)) 
				PRINT(SUBSTRING(@SQLDelta,16001,20000)) 
				PRINT(SUBSTRING(@SQLDelta,20001,24000)) 
				PRINT(SUBSTRING(@SQLDelta,24001,28000)) 
			END
		IF @IncrementalFact = 1 AND @LoadPattern = 'Replacement' AND @FactEngineIsSQLFlag = 1 
			BEGIN
				PRINT(LEFT(@SQLReplacement,4000)) 
				PRINT(SUBSTRING(@SQLReplacement,4001,8000)) 
				PRINT(SUBSTRING(@SQLReplacement,8001,12000)) 
				PRINT(SUBSTRING(@SQLReplacement,12001,16000)) 
				PRINT(SUBSTRING(@SQLReplacement,16001,20000)) 
				PRINT(SUBSTRING(@SQLReplacement,20001,24000)) 
				PRINT(SUBSTRING(@SQLReplacement,24001,28000)) 
			END
	END
					
			

DROP TABLE #Dimensions
DROP TABLE #DW
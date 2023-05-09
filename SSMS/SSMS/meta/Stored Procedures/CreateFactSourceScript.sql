


/**********************************************************************************************************************************************************************
The purpose of this scripts is to create the source code for fact and bridge loads. 
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [meta].[CreateFactSourceScript]

@Table NVARCHAR(128),--Input is the dimensions name without schema
@PrintSQL NVARCHAR(MAX) OUTPUT

AS

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/

DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10)
DECLARE @DatabaseNameStage NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameStage')
DECLARE @DatabaseNameDW NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameDW')
DECLARE @SurrogatKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'SurrogateKeySuffix')
DECLARE @BusinessKeySuffix NVARCHAR(10) =(SELECT VariableValue FROM meta.Variables WHERE VariableName = 'BusinessKeySuffix')
DECLARE @IsCloudFlag BIT = IIF((SELECT VariableValue FROM meta.Variables WHERE VariableName = 'IsCloudFlag') = '1',1,0)
DECLARE @StageSchemaTable TABLE (SchemaName NVARCHAR(10)) 
INSERT @StageSchemaTable EXEC('SELECT DISTINCT TABLE_SCHEMA FROM [' + @DatabaseNameStage + '].INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @Table + ''' AND TABLE_SCHEMA IN (''dbo'',''stage'')')
DECLARE @StageSchema NVARCHAR(10) = (SELECT IIF(@IsCloudFlag = 1,'stage',(SELECT SchemaName FROM @StageSchemaTable))) --If on-premise and stageschema has not been changed

/**********************************************************************************************************************************************************************
1. Create and insert data into table variables
***********************************************************************************************************************************************************************/

DECLARE @InformationSchema TABLE (DatabaseName NVARCHAR(128),TableName NVARCHAR(128), ColumnName NVARCHAR(128), OrdinalPosition INT, DataType NVARCHAR(128), PrimaryKey INT)
DECLARE @Dimensions TABLE (TableName NVARCHAR(128), DimensionTable NVARCHAR(128), ColumnName NVARCHAR(128),ColumnMapping NVARCHAR(128),RolePlayingDimension NVARCHAR(128),IsSCD2Dimension NVARCHAR(10), IsSCD2CompositeKeyDimension NVARCHAR(10),OrdinalPosition INT,NewDimension NVARCHAR(128), ErrorValue NVARCHAR(128))
DECLARE @SCDCombinedKeys TABLE (DimensionTable NVARCHAR(128), ColumnName NVARCHAR(128), ColumnMapping NVARCHAR(128),OrdinalPosition INT, RolePlayingDimension NVARCHAR(128),NewDimension NVARCHAR(128), ErrorValue NVARCHAR(128))
DECLARE @SCDFromSource TABLE (DimensionTable NVARCHAR(128))

/*Generates the combined information schema*/
INSERT @InformationSchema EXEC('SELECT  ''Stage''
										,COLUMNS.TABLE_NAME
										,COLUMNS.COLUMN_NAME
										,ROW_NUMBER() OVER (ORDER BY COLUMNS.TABLE_NAME) AS ORDINAL_POSITION
										,COLUMNS.DATA_TYPE
										,CASE WHEN KEY_COLUMN_USAGE.COLUMN_NAME IS NULL THEN 0 ELSE 1 END AS PRIMARY_KEY
								FROM 
									[' + @DatabaseNameStage + '].INFORMATION_SCHEMA.COLUMNS
								LEFT JOIN 
									[' + @DatabaseNameDW + '].INFORMATION_SCHEMA.KEY_COLUMN_USAGE
										ON COLUMNS.TABLE_NAME = KEY_COLUMN_USAGE.TABLE_NAME 
										AND COLUMNS.COLUMN_NAME = KEY_COLUMN_USAGE.COLUMN_NAME
								WHERE 
									    COLUMNS.TABLE_NAME = ''' + @Table + ''' 
									AND COLUMNS.COLUMN_NAME NOT LIKE ''DW%''
									AND COLUMNS.TABLE_SCHEMA = ''' + @StageSchema + '''

								UNION ALL

								SELECT  ''DW''
										,COLUMNS.TABLE_NAME
										,COLUMNS.COLUMN_NAME
										,ROW_NUMBER() OVER (ORDER BY COLUMNS.TABLE_NAME) AS ORDINAL_POSITION
										,COLUMNS.DATA_TYPE
										,CASE WHEN KEY_COLUMN_USAGE.COLUMN_NAME IS NULL THEN 0 ELSE 1 END AS PRIMARY_KEY
								FROM 
									[' + @DatabaseNameDW + '].INFORMATION_SCHEMA.COLUMNS
								LEFT JOIN 
									[' + @DatabaseNameDW + '].INFORMATION_SCHEMA.KEY_COLUMN_USAGE
										ON COLUMNS.TABLE_NAME = KEY_COLUMN_USAGE.TABLE_NAME 
										AND COLUMNS.COLUMN_NAME = KEY_COLUMN_USAGE.COLUMN_NAME
								WHERE 
									    COLUMNS.TABLE_NAME = ''' + @Table + ''' 
									AND COLUMNS.TABLE_SCHEMA = ''fact''
									AND COLUMNS.COLUMN_NAME NOT LIKE ''DW%'''
								
								)

							
/*Generates the mapping dataset between fact/bridge and dimensions*/
INSERT @Dimensions EXEC meta.CreateDWRelations @Table = @Table;

/*Generates a dataset with composite SCD keys*/
INSERT @SCDCombinedKeys SELECT Dimensions.DimensionTable
							  ,InformationSchema.ColumnName
							  ,Dimensions.ColumnMapping
							  ,ROW_NUMBER() OVER (ORDER BY Dimensions.DimensionTable,Dimensions.RolePlayingDimension,InformationSchema.ColumnName) AS ORDINAL_POSITION
							  ,CASE WHEN Dimensions.RolePlayingDimension IS NULL THEN Dimensions.DimensionTable 
									ELSE Dimensions.RolePlayingDimension 
							   END
							  ,CASE WHEN ROW_NUMBER() OVER (PARTITION BY CASE WHEN Dimensions.RolePlayingDimension IS NULL THEN Dimensions.DimensionTable 
																			  ELSE Dimensions.RolePlayingDimension 
																		 END ORDER BY Dimensions.DimensionTable,Dimensions.RolePlayingDimension,InformationSchema.ColumnName)  = 1 THEN N'Yes' 
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

INSERT @SCDFromSource EXEC('SELECT DISTINCT TABLE_NAME FROM [' + @DatabaseNameStage + '].INFORMATION_SCHEMA.COLUMNS WHERE REPLACE(COLUMN_NAME,TABLE_NAME,'''') IN (''IsCurrent'',''ValidFromDate'',''ValidToDate'')') 							

/**********************************************************************************************************************************************************************
2. Create Loop counter variables and SCD2FromSource variable
***********************************************************************************************************************************************************************/

DECLARE @Counter INT 
DECLARE @MaxColumns INT  --Number of columns from stage
DECLARE @MaxSCDJoinColumns INT --Max position of composite SCD2 key columns
DECLARE @MaxJoinColumns INT --Max position of key columns from fact/bridge
DECLARE @MinIDNoSCDColumns INT --Min position of key column from stage which is not an SCD column
DECLARE @MaxColumnsKeys INT --Max position of primary key columns i fact/bridge
DECLARE @MaxColumnsFact INT --Number of columns in fact/bridge

SELECT 
	   @Counter = 1
	  ,@MaxColumns = (SELECT MAX(OrdinalPosition) FROM @InformationSchema WHERE DatabaseName = 'Stage' )
	  ,@MaxJoinColumns = (SELECT MAX(OrdinalPosition) FROM @Dimensions) 
	  ,@MaxSCDJoinColumns = (SELECT MAX(OrdinalPosition) FROM @SCDCombinedKeys) 
	  ,@MaxColumnsKeys = (SELECT MAX(OrdinalPosition) FROM @InformationSchema WHERE PrimaryKey = 1 AND DatabaseName = 'DW')
	  ,@MaxColumnsFact = (SELECT MAX(OrdinalPosition) FROM @InformationSchema WHERE DatabaseName = 'DW')
	  ,@MinIDNoSCDColumns = (SELECT MIN(OrdinalPosition) FROM @Dimensions WHERE NewDimension = 'Yes' AND IsSCD2Dimension = 'No') 
	 
/**********************************************************************************************************************************************************************
3. Create position and support variables
***********************************************************************************************************************************************************************/

DECLARE @HasCalendarKey INT 
DECLARE @PositionFirstNonSCDColumn INT

SELECT
	   @HasCalendarKey = CASE WHEN (SELECT COUNT(*) FROM @InformationSchema WHERE ColumnName = 'Calendar' + @BusinessKeySuffix) > 0 THEN 1 ELSE 0 END --Check if CalendarKey is present
	  ,@PositionFirstNonSCDColumn = (SELECT MIN(I.OrdinalPosition) FROM @InformationSchema I INNER JOIN @Dimensions D ON D.ColumnName = I.ColumnName WHERE IsSCD2Dimension = 'No') --Gives the position of the first non SCD column

/**********************************************************************************************************************************************************************
4. Create the select part of the source code for SCD dimensions
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderSelectSCD VARCHAR(MAX)
DECLARE @SelectSCD VARCHAR(MAX)

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
														THEN  'UPPER(' + InformationSchema.TableName + '.[' + InformationSchema.ColumnName + ']) AS [' + InformationSchema.ColumnName + ']'
													WHEN InformationSchema.DataType LIKE '%date%' 
														THEN  'CAST(' + InformationSchema.TableName + '.[' + InformationSchema.ColumnName + '] AS DATE) AS [' + InformationSchema.ColumnName + ']'
													ELSE '' + InformationSchema.TableName + '.[' + InformationSchema.ColumnName + ']' 
												 END
										ELSE CASE 
												WHEN InformationSchema.DataType LIKE '%char%' 
													THEN  'UPPER([' + InformationSchema.ColumnName + ']) AS [' + InformationSchema.ColumnName + ']'
												WHEN InformationSchema.DataType LIKE '%date%' 
													THEN  'CAST([' + InformationSchema.ColumnName + '] AS DATE) AS [' + InformationSchema.ColumnName + ']'
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

DECLARE @PlaceholderSelect VARCHAR(MAX) = ''
DECLARE @Select VARCHAR(MAX) = ''

WHILE @Counter <= @MaxColumns

BEGIN

	SELECT @PlaceholderSelect = ',[' + InformationSchema.ColumnName + ']' + @CRLF
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
6. Create the select SCD ID part for source code and SCD ID with error handling for merge part
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderIDSCD VARCHAR(MAX)
DECLARE @IDSCD VARCHAR(MAX)

WHILE @Counter <= @MaxSCDJoinColumns

BEGIN

	SELECT @PlaceholderIDSCD = ',' + RolePlayingDimension + '.[' + DimensionTable + @SurrogatKeySuffix + ']' + CASE 
																								WHEN RolePlayingDimension <> DimensionTable 
																									THEN ' AS [' + RolePlayingDimension + @SurrogatKeySuffix + ']'
	  																							ELSE '' 
																							END + @CRLF
	FROM 
		@SCDCombinedKeys
	WHERE 
			@Counter = OrdinalPosition 
		AND NewDimension = 'Yes' 

	SET @IDSCD = CONCAT(@IDSCD,@PlaceholderIDSCD)

	SET @PlaceholderIDSCD = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1

/**********************************************************************************************************************************************************************
7. Create the the left join part for SCD dimensions
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderLeftJoinSCD VARCHAR(MAX) 
DECLARE @LeftJoinSCD VARCHAR(MAX) 

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
																																										THEN @Table + '.[CalendarKey] BETWEEN ' + RolePlayingDimension + '.[DWValidFromDate] AND ' + RolePlayingDimension + '.[DWValidToDate]' 
																																									WHEN @HasCalendarKey = 1 AND SCDFromSource.DimensionTable IS NOT NULL
																																										THEN @Table + '.[CalendarKey] BETWEEN ' + RolePlayingDimension + '.[' + SCDFromSource.DimensionTable + 'ValidFromDate] AND ' + RolePlayingDimension + '.[' + SCDFromSource.DimensionTable + 'ValidToDate]' 
																																									WHEN @HasCalendarKey = 0 AND SCDFromSource.DimensionTable IS NOT NULL
																																										THEN RolePlayingDimension + '.[' + SCDFromSource.DimensionTable + 'IsCurrent] = 1 ' 
																																									ELSE RolePlayingDimension + '.[DWIsCurrent] = 1 ' 
																																								 END +  @CRLF + 'AND ' + RolePlayingDimension + '.[' + ColumnMapping  + '] = ' + @Table + '.[' + ColumnName + ']' 
										ELSE 'AND ' + RolePlayingDimension + '.[' + ColumnMapping + '] = ' + @Table + '.[' + ColumnName + ']' 
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
8. Fill out dynamic SQL variables
***********************************************************************************************************************************************************************/


SET @PrintSQL = 'SELECT ' + @CRLF + ISNULL(@SelectSCD,'') + ISNULL(@IDSCD,'') + ISNULL(@Select,'') + 'FROM [' + @StageSchema + '].[' + @Table + ']' + @CRLF + ISNULL(@LeftJoinSCD,'')

SET NOCOUNT OFF
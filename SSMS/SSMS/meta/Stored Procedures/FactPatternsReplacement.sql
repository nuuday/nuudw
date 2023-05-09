/**********************************************************************************************************************************************************************
The purpose of this scripts is to insert delta rows in the fact temp table
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [meta].[FactPatternsReplacement]

@Table NVARCHAR(128),--Input is the fact name without schema
@DestinationSchema NVARCHAR(128),
@CleanUpPartitionsFlag BIT,
@PrintSQL BIT

AS

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/

DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10)
DECLARE @DatabaseNameStage NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameStage')
DECLARE @DatabaseNameDW NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameDW')
DECLARE @SurrogateKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'SurrogateKeySuffix')
DECLARE @BusinessKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'BusinessKeySuffix')
DECLARE @IsCloudFlag BIT = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'IsCloudFlag')
DECLARE @PrimaryKeys TABLE (TableName NVARCHAR(128), ColumnName NVARCHAR(128))
DECLARE @StageSchemaTable TABLE (SchemaName NVARCHAR(10)) 
INSERT @StageSchemaTable EXEC('SELECT DISTINCT TABLE_SCHEMA FROM [' + @DatabaseNameStage + '].INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @Table + ''' AND TABLE_SCHEMA IN (''dbo'',''stage'')')
DECLARE @StageSchema NVARCHAR(10) = (SELECT IIF(@IsCloudFlag = 1,'stage',(SELECT SchemaName FROM @StageSchemaTable))) --If on-premise and stageschema has not been changed

/**********************************************************************************************************************************************************************
1. Create and insert data into table variables
***********************************************************************************************************************************************************************/

DECLARE @InformationSchema TABLE (DatabaseName NVARCHAR(128),TableName NVARCHAR(128), ColumnName NVARCHAR(128), OrdinalPosition INT, DataType NVARCHAR(128), PrimaryKey INT)
/*Generates the combined information schema*/
INSERT @InformationSchema EXEC('WITH PrimaryKeys AS
								(
								SELECT DISTINCT
										tables.name AS TableName
									   ,all_columns.name AS ColumnName
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
									   extended_properties.name = ''PrimaryKeyColumn''
									   AND tables.name = ''' + @Table + '''
								)

								SELECT  ''DW''
										,COLUMNS.TABLE_NAME
										,COLUMNS.COLUMN_NAME
										,ROW_NUMBER() OVER (ORDER BY COLUMNS.TABLE_NAME) AS ORDINAL_POSITION
										,COLUMNS.DATA_TYPE
										,CASE WHEN PrimaryKeys.ColumnName IS NULL THEN 0 ELSE 1 END AS PRIMARY_KEY
								FROM 
									[' + @DatabaseNameDW + '].INFORMATION_SCHEMA.COLUMNS
								LEFT JOIN
									PrimaryKeys
										ON PrimaryKeys.ColumnName = COLUMNS.COLUMN_NAME
								WHERE 
									    COLUMNS.TABLE_NAME = ''' + @Table + ''' 
									AND COLUMNS.TABLE_SCHEMA IN (''fact'',''bridge'')
									AND COLUMNS.COLUMN_NAME NOT LIKE ''DW%''
									AND COLUMNS.COLUMN_NAME != ''LastValueLoaded'''
								
								)

/**********************************************************************************************************************************************************************
2. Create Loop counter variables and SCD2FromSource variable
***********************************************************************************************************************************************************************/

DECLARE @Counter INT 
DECLARE @MaxColumns INT  --Number of columns from stage
DECLARE @MaxSCDJoinColumns INT --Max position of composite SCD2 key columns
DECLARE @MaxJoinColumns INT --Max position of key columns from fact/bridge
DECLARE @MaxColumnsKeys INT --Max position of primary key columns i fact/bridge
DECLARE @MaxColumnsFact INT --Number of columns in fact/bridge
DECLARE @MinKeyCounter INT
DECLARE @PrimaryKeyColumn NVARCHAR(500)


SELECT 
	   @Counter = 1
	  ,@MaxColumns = (SELECT MAX(OrdinalPosition) FROM @InformationSchema WHERE DatabaseName = 'DW' )
	  ,@MaxColumnsKeys = (SELECT MAX(OrdinalPosition) FROM @InformationSchema WHERE PrimaryKey = 1 AND DatabaseName = 'DW')
	  ,@MinKeyCounter  = (SELECT MIN(OrdinalPosition) FROM @InformationSchema WHERE PrimaryKey = 1 AND DatabaseName = 'DW')
	  ,@PrimaryKeyColumn = (SELECT TOP 1 ColumnName FROM @InformationSchema WHERE PrimaryKey = 1 AND DatabaseName = 'DW')

/**********************************************************************************************************************************************************************
3. Create the select part 
***********************************************************************************************************************************************************************/

DECLARE @PlaceholderInsertColumns VARCHAR(MAX) = ''
DECLARE @InsertColumns VARCHAR(MAX) = ''
DECLARE @PlaceholderSelectDelta VARCHAR(MAX) = ''
DECLARE @SelectDelta VARCHAR(MAX) = ''

WHILE @Counter <= @MaxColumns

BEGIN

	SELECT @PlaceholderInsertColumns	= IIF(@Counter = 1,'',',') + '[' + InformationSchema.ColumnName + ']' + @CRLF
		  ,@PlaceholderSelectDelta  = IIF(@Counter = 1,'',',') + CASE 
																	WHEN ColumnName NOT LIKE '%ID' AND ColumnName NOT LIKE '%Code' AND ColumnName NOT LIKE '%Flag'AND ColumnName NOT LIKE '%Number' AND Datatype IN ('Decimal','Numeric','int','bigint','float','smallint') THEN '-'
																	ELSE ''
																 END + 'fact.[' + InformationSchema.ColumnName + ']' + @CRLF
	FROM 
		@InformationSchema AS InformationSchema	
	WHERE 
		@Counter = InformationSchema.OrdinalPosition 
		AND InformationSchema.DatabaseName = 'DW'

	SET @InsertColumns = CONCAT(@InsertColumns,@PlaceholderInsertColumns)
	SET @SelectDelta = CONCAT(@SelectDelta,@PlaceholderSelectDelta)

	SET @PlaceholderInsertColumns = ''
	SET @PlaceholderSelectDelta = ''

	SET @Counter = @Counter + 1

END

SET @Counter = 1


/**********************************************************************************************************************************************************************
5. Fill out dynamic SQL variables
***********************************************************************************************************************************************************************/
DECLARE @VariablesSQL NVARCHAR(MAX)
DECLARE @WhereSQL NVARCHAR(MAX) 
DECLARE @NewDelta NVARCHAR(MAX)
DECLARE @DeleteFromFact NVARCHAR(MAX) --Holds the SCD1 part of the Merge Join Script
DECLARE @SQL NVARCHAR(MAX)

SET @VariablesSQL = '
DECLARE @MinDate NVARCHAR(50)
DECLARE @MaxDate NVARCHAR(50)

SET @MinDate = (SELECT MIN([' + @PrimaryKeyColumn + ']) FROM [' + @DatabaseNameDW + '].[' + @StageSchema + '].[' + @Table + '])
SET @MaxDate = (SELECT MAX([' + @PrimaryKeyColumn + ']) FROM [' + @DatabaseNameDW + '].[' + @StageSchema + '].[' + @Table + '])' + @CRLF + @CRLF

SET @WhereSQL = 'WHERE [' + @PrimaryKeyColumn + '] >= @MinDate AND [' + @PrimaryKeyColumn + '] <= @MaxDate'

SET @NewDelta = 
'INSERT INTO [' + @DatabaseNameDW + '].[' + @DestinationSchema + '].['+ @Table + '_Temp] WITH (TABLOCK)
(' + ISNULL(@InsertColumns,'') + ',DWCreatedDate, DWModifiedDate)
 SELECT 
	' + ISNULL(@SelectDelta ,'')
	  + '
	  ,''1900-01-01''
	  ,''1900-01-01''
 FROM [' + @DatabaseNameDW + '].[' + @DestinationSchema +'].['+ @Table + '] AS fact'  + @CRLF + @WhereSQL + @CRLF 


SET @DeleteFromFact = '
DELETE fact WITH (TABLOCK)
FROM
	[' + @DatabaseNameDW + '].[' + @DestinationSchema + '].['+ @Table + '] AS fact'  + @CRLF + @WhereSQL


SET @SQL = IIF(@CleanUpPartitionsFlag = 0,CONCAT('BEGIN TRAN ',@VariablesSQL,@NewDelta,@DeleteFromFact,' COMMIT TRAN'),CONCAT('BEGIN TRAN ',@VariablesSQL,@DeleteFromFact,' COMMIT TRAN'))

/**********************************************************************************************************************************************************************
6. Execute dynamic SQL variables
***********************************************************************************************************************************************************************/

IF @PrintSQL = 0

	BEGIN
		
		EXEC(@SQL)

	END

ELSE

	BEGIN

		IF @CleanUpPartitionsFlag = 0

			BEGIN

				PRINT('BEGIN TRAN ') + @CRLF + @CRLF
				PRINT(@VariablesSQL)
				PRINT(@NewDelta) + @CRLF + @CRLF
				PRINT(@DeleteFromFact) + @CRLF + @CRLF
				PRINT(' COMMIT TRAN ') + @CRLF + @CRLF

			END

	    ELSE

			BEGIN
			    PRINT(@VariablesSQL) + @CRLF + @CRLF
				PRINT(@DeleteFromFact)

			END
			
	END

SET NOCOUNT OFF
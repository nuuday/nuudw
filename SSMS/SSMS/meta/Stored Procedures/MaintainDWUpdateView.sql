
/**********************************************************************************************************************************************************************
The purpose of this scripts is to create and execute the update view between stage and dw. 
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [meta].[MaintainDWUpdateView]

@Table NVARCHAR(100),
@DestinationSchema NVARCHAR(50),
@PrintSQL BIT

AS

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/

DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10) 
DECLARE @DatabaseNameDW NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameDW')
DECLARE @SurrogateKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'SurrogateKeySuffix')
DECLARE @BusinessKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'BusinessKeySuffix')
DECLARE @FactIsIncremental BIT = (SELECT FactAndBridgeIncrementalFlag FROM meta.BusinessMatrix WHERE TableName = @Table AND DestinationSchema = @DestinationSchema)
DECLARE @LoadPattern NVARCHAR(50) = (SELECT LoadPattern FROM meta.BusinessMatrix WHERE TableName = @Table)
DECLARE @UpdateViewFlag BIT = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'MaintainDWUpdateViewFlag')
DECLARE @ViewName NVARCHAR(100) = meta.[SplitCamelCase](@Table)

/**********************************************************************************************************************************************************************
1. Create and insert data into table variables
**********************************************************************************************************************************************************************/

DECLARE @InformationSchema TABLE (DatabaseName NVARCHAR(128), ColumnName NVARCHAR(128), OrdinalPosition INT, OriginalColumnName NVARCHAR(128))
DECLARE @InformationSchemaViews TABLE (TableName NVARCHAR(128), TableSchema NVARCHAR(128), ViewDefinition NVARCHAR(MAX))
DECLARE @ViewDefinition TABLE (SelectStatement NVARCHAR(MAX),FromStatement NVARCHAR(MAX))

/*Generates the combined information schema*/
INSERT @InformationSchema EXEC('SELECT ''DW'' AS [DATABASE_NAME]
										,CASE 
											WHEN (''' + @DestinationSchema + ''' IN (''fact'',''bridge'') AND (COLUMN_NAME LIKE ''%Code'' OR COLUMN_NAME LIKE ''%Name'' OR COLUMN_NAME LIKE ''%Label'')) OR (''' + @DestinationSchema + ''' = ''dim'' AND COLUMN_NAME NOT LIKE ''%' + @SurrogateKeySuffix + ''')
												THEN meta.SplitCamelCase(COLUMN_NAME)   
											ELSE COLUMN_NAME
										 END AS COLUMN_NAME
										,[ORDINAL_POSITION]
										,[COLUMN_NAME] AS ORIGINAL_COLUMN_NAME
								FROM 
									[' + @DatabaseNameDW + '].INFORMATION_SCHEMA.COLUMNS
								WHERE 
										TABLE_NAME = ''' + @Table + ''' 
									AND COLUMN_NAME <> CASE WHEN ''' + @DestinationSchema + ''' = ''fact'' THEN ''' + @Table + @SurrogateKeySuffix + ''' 
														    ELSE '''' 
													   END 
									AND TABLE_SCHEMA = ''' + @DestinationSchema + ''' 
									AND COLUMN_NAME NOT LIKE ''DW%''
						 
								
								UNION
								
								SELECT ''View'' AS [DATABASE_NAME]
										,[COLUMN_NAME]
										,[ORDINAL_POSITION]
										,REPLACE([COLUMN_NAME],'' '','''') AS ORIGINAL_COLUMN_NAME
								FROM 
									[' + @DatabaseNameDW + '].INFORMATION_SCHEMA.COLUMNS
								WHERE 
										TABLE_SCHEMA = ''' + @DestinationSchema +  'View'' 
									AND TABLE_NAME = '''  + @ViewName + ''' 
									AND COLUMN_NAME NOT LIKE ''DW%''')

INSERT @InformationSchemaViews EXEC('SELECT   Views.[name] AS TABLE_NAME
											 ,Schemas.[name] AS TABLE_SCHEMA
											 ,[definition] AS VIEW_DEFINITION
									 FROM 
									 	 [' + @DatabaseNameDW + '].[sys].[views] AS Views
									 INNER JOIN  
									 	 [' + @DatabaseNameDW + '].[sys].[sql_modules] AS Modules 
											 ON Modules.object_id = Views.object_id
									 INNER JOIN  
										 [' + @DatabaseNameDW + '].[sys].[schemas] AS Schemas 
											 ON Schemas.schema_id = Views.schema_id
									 WHERE 
											 Views.Name = ''' + @ViewName + ''' 
										 AND Schemas.Name = ''' + @DestinationSchema +  'View''')
		
							
/*Generates the view definition*/
INSERT @ViewDefinition SELECT REPLACE(REPLACE(ViewDefinition,RIGHT(ViewDefinition,LEN(ViewDefinition)-CHARINDEX('FROM [' + @DestinationSchema + '].[' + @Table + ']',ViewDefinition)+1),''),'CREATE VIEW', '') AS SelectStatement
							 ,RIGHT(ViewDefinition,LEN(ViewDefinition)-CHARINDEX('FROM [' + @DestinationSchema + '].[' + @Table + ']',ViewDefinition)+1) AS FromStatement
                       FROM
							 @InformationSchemaViews

						
/**********************************************************************************************************************************************************************
2. Create Loop counter variables
**********************************************************************************************************************************************************************/

DECLARE @Columns AS INT --Holds the number of columns in the table
DECLARE @Counter AS INT --Just a counter for the loop

SELECT 
	@Columns = (SELECT MAX(OrdinalPosition) + CASE WHEN @DestinationSchema IN ('fact','bridge') THEN 1 ELSE 0 END FROM @InformationSchema WHERE DatabaseName = 'DW'), --Counts the number of columns in the table
	@Counter = 1

/**********************************************************************************************************************************************************************
3. Create variables for determine first change between stage and dw
**********************************************************************************************************************************************************************/

DECLARE @PositionFirstChange INT --The ordinal position of the first change

SELECT 
	@PositionFirstChange = (SELECT TOP 1 InformationSchema.OrdinalPosition 
							FROM 
								@InformationSchema AS InformationSchema
							LEFT JOIN 
								(SELECT * FROM @InformationSchema WHERE DatabaseName = 'View') AS Views
									ON Views.OriginalColumnName = InformationSchema.OriginalColumnName
							WHERE 
									Views.ColumnName IS NULL
							ORDER BY 
								InformationSchema.OrdinalPosition) --Counts the position of the first change


/**********************************************************************************************************************************************************************
4. Create variable for holding the select and from statements
**********************************************************************************************************************************************************************/

DECLARE @SelectStatement NVARCHAR(MAX) --Variable for the current select part of the view
DECLARE @FromStatement NVARCHAR(MAX) --Variable for the current from part of the view

SELECT 
	@SelectStatement = (SELECT SelectStatement FROM @ViewDefinition), --Adds the current select part to the variable
	@FromStatement = (SELECT FromStatement FROM @ViewDefinition) --Adds the current from part to the variable


/**********************************************************************************************************************************************************************
5. Generates the columns for the alter view script
**********************************************************************************************************************************************************************/

DECLARE @PlaceholderColumnNameUpdateView AS NVARCHAR(MAX) --Placeholder used in the loop for the update view script
DECLARE @ColumnNameUpdateView AS NVARCHAR(MAX) --Variable which hold the value of @ColumnNameUpdateView for each loop

BEGIN

WHILE @Counter <= @Columns

BEGIN

	SELECT @PlaceholderColumnNameUpdateView = ',[' + InformationSchema.OriginalColumnName + '] AS [' + InformationSchema.ColumnName + ']' + @CRLF 
				     
	FROM 
		@InformationSchema AS InformationSchema
	LEFT JOIN 
		(SELECT * FROM @InformationSchema WHERE DatabaseName = 'View') AS Views 
			ON Views.ColumnName = InformationSchema.ColumnName
	WHERE 
			Views.ColumnName IS NULL 
		AND InformationSchema.DatabaseName = 'DW' 
		AND InformationSchema.OrdinalPosition = @Counter

	SET @ColumnNameUpdateView = CONCAT(@ColumnNameUpdateView,@PlaceholderColumnNameUpdateView)

	SET @PlaceholderColumnNameUpdateView = ''

	SET @Counter = @Counter + 1

END


/**********************************************************************************************************************************************************************
6.Fill out the dynamic SQL script variables
**********************************************************************************************************************************************************************/

DECLARE @PrepareViewScript NVARCHAR(MAX) --Variable where the view script is created
DECLARE @UpdateViewScript NVARCHAR(MAX) --Variable for the final alter view script
DECLARE @UpdateTempViewScript NVARCHAR(MAX)

SET @PrepareViewScript = 'ALTER VIEW ' + CONCAT(REPLACE(@SelectStatement,'''',''''''),@ColumnNameUpdateView,REPLACE(@FromStatement,'''','''''')) END
					

/*Generates the create view script so it can be executed in the DW database*/
SET @UpdateViewScript = CASE WHEN @PositionFirstChange IS NULL THEN NULL 
                             ELSE 'USE [' + @DatabaseNameDW + ']' + @CRLF + 'EXEC(''' + @PrepareViewScript + ''')'
					    END

SET @UpdateTempViewScript = CASE WHEN @PositionFirstChange IS NULL THEN NULL 
                             ELSE 'USE [' + @DatabaseNameDW + ']' + @CRLF + 'EXEC(''' + REPLACE(REPLACE(@PrepareViewScript ,'[factView].[' + @Table + ']','[factView].[' + @Table + '_Temp]'), 'FROM [' + @DestinationSchema + '].[' + @Table + ']','FROM [' + @DestinationSchema + '].[' + @Table + '_Temp]') + ''')'
							END

/**********************************************************************************************************************************************************************
7. Execute dynamic SQL
***********************************************************************************************************************************************************************/

IF @PrintSQL = 0

	BEGIN 

		EXEC(@UpdateViewScript)

		IF @DestinationSchema = 'fact' AND @LoadPattern <> 'Standard' AND @FactIsIncremental = 1 AND @UpdateViewFlag = 1
			BEGIN
				EXEC(@UpdateTempViewScript)
			END

	END

ELSE

	BEGIN 

		PRINT(@UpdateViewScript) + @CRLF + @CRLF

		IF @DestinationSchema = 'fact' AND @LoadPattern <> 'Standard' AND @FactIsIncremental = 1 AND @UpdateViewFlag = 1
			BEGIN
				PRINT(@UpdateTempViewScript)
			END

	END

SET NOCOUNT OFF
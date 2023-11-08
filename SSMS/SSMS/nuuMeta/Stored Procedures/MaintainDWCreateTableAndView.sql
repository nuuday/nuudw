

/**********************************************************************************************************************************************************************
The purpose of this scripts is to create and execute the create table and create view script between stage and dw. 
***********************************************************************************************************************************************************************/



CREATE PROCEDURE [nuuMeta].[MaintainDWCreateTableAndView]

@DestinationSchema NVARCHAR(10),--Input is the destination schema (dim, fact or bridge)
@DestinationTable NVARCHAR(100),--Input is the table name without schema
@PrintSQL BIT = 0 --Enter 1 if you want to print the dynamic SQL and 0 if you want to execute the dynamic SQL

AS

SET NOCOUNT ON

/*
DECLARE
	@DestinationTable NVARCHAR(100) = 'ProductTransactions',
	@DestinationSchema NVARCHAR(10) = 'fact', 
	@PrintSQL BIT = 1
--*/

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/

DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10) 
DECLARE @SurrogatKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM nuuMetaView.Variables WHERE VariableName = 'SurrogateKeySuffix')
DECLARE @BusinessKeySuffix NVARCHAR(10) = (SELECT VariableValue FROM nuuMetaView.Variables WHERE VariableName = 'BusinessKeySuffix')
DECLARE @LoadPattern NVARCHAR(50) = (SELECT LoadPattern FROM nuuMeta.DWObject WHERE DWObjectName = @DestinationTable)
DECLARE @ViewName NVARCHAR(100) = @DestinationTable
DECLARE @StageSchema NVARCHAR(10) = 'stage'
DECLARE @StageTablePrefix NVARCHAR(100) = @DestinationSchema + '_'
DECLARE @StageTable NVARCHAR(128) = @StageTablePrefix + @DestinationTable
DECLARE @TruncateFlag BIT = 0
DECLARE @DefaultDimensionMemberID NVARCHAR(50) = (SELECT VariableValue FROM nuuMetaView.Variables WHERE VariableName = 'DefaultDimensionMemberID')


/**********************************************************************************************************************************************************************
Create and insert data into table variables
***********************************************************************************************************************************************************************/

DROP TABLE IF EXISTS #InformationSchema
DROP TABLE IF EXISTS #DWRelations
DROP TABLE IF EXISTS #DimensionCombinedKeys

CREATE TABLE #InformationSchema (
	StageSchema SYSNAME,
	StageTable SYSNAME,
	DestinationSchema SYSNAME,
	DestinationTable SYSNAME,
	ColumnName NVARCHAR(128), 
	OrdinalPosition INT, 
	DataType NVARCHAR(128), 
	CharacterMaximumLenght INT, 
	NumericPrecision INT, 
	NumericScale INT, 
	IsPrimaryDimensionKey BIT,
	IsType2 BIT
)

CREATE TABLE #DWRelations (TableName NVARCHAR(128), DimensionName NVARCHAR(128), TableColumnName NVARCHAR(128), DimensionColumnMappingName NVARCHAR(128), RolePlayingDimensionName NVARCHAR(128), IsType2DimensionFlag NVARCHAR(10), IsType2CompositeKeyDimensionFlag NVARCHAR(10), ColumnOrdinalPosition INT, IsNewDimensionFlag NVARCHAR(128), DefaultErrorValue NVARCHAR(128))
CREATE TABLE #DimensionCombinedKeys (TableName NVARCHAR(128), ColumnName NVARCHAR(128), DimensionTable NVARCHAR(128))

/*Generates a dataset with the combined information schema*/

INSERT INTO #InformationSchema (StageSchema, StageTable, DestinationSchema, DestinationTable, ColumnName, OrdinalPosition, DataType, CharacterMaximumLenght, NumericPrecision, NumericScale, IsPrimaryDimensionKey)
SELECT
	@StageSchema AS StageSchema,
	@StageTable AS StageTable,
	@DestinationSchema AS DestinationSchema,
	@DestinationTable AS DestinationTable,
	COLUMN_NAME,
	ORDINAL_POSITION,
	DATA_TYPE,
	CHARACTER_MAXIMUM_LENGTH,
	NUMERIC_PRECISION,
	NUMERIC_SCALE,
	IIF(COLUMN_NAME LIKE '%Key' AND @DestinationSchema = 'dim', 1, 0) IsPrimaryDimensionKey
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE
	TABLE_SCHEMA = @StageSchema
	AND TABLE_NAME = @StageTable
	AND COLUMN_NAME NOT LIKE 'DW%'

UPDATE c
SET IsType2 = IIF(type2.ColumnName = '*' OR type2.ColumnName = c.ColumnName, 1, 0)
FROM #InformationSchema c
OUTER APPLY (
	SELECT 
		Type.[value] AS ColumnName
	FROM nuuMeta.DWObject dw
	OUTER APPLY STRING_SPLIT( NULLIF( dw.HistoryTrackingColumns, '' ), ',', 1 ) Type
	WHERE 
		dw.HistoryTrackingColumns <> ''
		AND dw.DWObjectType = 'Dimension'
		AND dw.DWObjectName = c.DestinationTable
) type2


INSERT #DWRelations 
EXEC nuuMeta.CreateDWRelations @StageTable

/*Populates @DimensionCombinedKeys to check if combined keys are used and in which dimensions they are used*/
INSERT #DimensionCombinedKeys  
SELECT
	dwr.TableName,
	dwr.TableColumnName,
	dwr.RolePlayingDimensionName
FROM #DWRelations AS dwr
WHERE --Only dimensions with composite keys are maintained
	dwr.RolePlayingDimensionName IN
	(
		SELECT
			RolePlayingDimensionName
		FROM #DWRelations
		WHERE TableColumnName LIKE RolePlayingDimensionName + '%'
		GROUP BY RolePlayingDimensionName
		HAVING COUNT( * ) > 1
	)
	AND dwr.TableColumnName LIKE dwr.RolePlayingDimensionName + '%'
							
						
/**********************************************************************************************************************************************************************
If the dimension has the following columns DimensionNameIsCurrent, DimensionNameValidFromDate and DimensionNameValidToDate Type 2 history is created in the source
***********************************************************************************************************************************************************************/
DECLARE @Type2HistoryFromSourceKey BIT

SET @Type2HistoryFromSourceKey = IIF((SELECT COUNT(ColumnName) FROM #InformationSchema WHERE REPLACE(ColumnName,@DestinationTable,'') IN ('IsCurrent', 'ValidFromDate', 'ValidToDate') ) = 3, 1, 0)

/**********************************************************************************************************************************************************************
Generates lines for the create table script
***********************************************************************************************************************************************************************/

DROP TABLE IF EXISTS #CreateLines 
CREATE TABLE #CreateLines (CreateType nvarchar(30), TableLine NVARCHAR(MAX), ViewLine NVARCHAR(MAX), OrdinalPosition int identity(1,1))

SET IDENTITY_INSERT #CreateLines ON

IF @DestinationSchema IN ('dim')
BEGIN

	INSERT INTO #CreateLines (TableLine, ViewLine, OrdinalPosition)
	VALUES ('[' + @DestinationTable + @SurrogatKeySuffix + '] INT IDENTITY PRIMARY KEY', '[' + @DestinationTable + @SurrogatKeySuffix + ']',0)

END

INSERT INTO #CreateLines (TableLine, ViewLine, OrdinalPosition)
SELECT TableLine, ViewLine, DENSE_RANK() OVER (ORDER BY MIN(q.OrdinalPosition)) OrdinalPosition
FROM (
	SELECT 
		CASE
			WHEN @DestinationSchema IN ('fact', 'bridge') AND ColumnName LIKE '%' + @BusinessKeySuffix AND ColumnName NOT IN (SELECT ColumnName FROM #DimensionCombinedKeys) 
				THEN '[' + REPLACE( ColumnName, @BusinessKeySuffix, @SurrogatKeySuffix ) + '] INT NOT NULL DEFAULT(' + @DefaultDimensionMemberID + ')'
			WHEN @DestinationSchema IN ('fact', 'bridge') AND ColumnName LIKE '%' + @BusinessKeySuffix AND ColumnName IN (SELECT ColumnName FROM #DimensionCombinedKeys) 
				THEN '[' + 	(SELECT DISTINCT DimensionTable FROM #DimensionCombinedKeys AS Dimension WHERE inf.ColumnName = Dimension.ColumnName)
					+ @SurrogatKeySuffix + '] INT NOT NULL DEFAULT(' + @DefaultDimensionMemberID 	+ ')'
			ELSE '[' + ColumnName + '] ' + UPPER( DataType ) +
					CASE
						WHEN DataType LIKE '%int%' OR DataType LIKE '%float%' THEN ''
						WHEN DataType IN ('nvarchar', 'varchar', 'nchar', 'char') AND CharacterMaximumLenght = -1 THEN '(MAX)'
						WHEN CharacterMaximumLenght IS NOT NULL THEN ' (' + CAST( CharacterMaximumLenght AS NVARCHAR(50) ) + ')'
						WHEN NumericPrecision IS NOT NULL THEN ' (' + CAST( NumericPrecision AS NVARCHAR(50) ) + ', ' + CAST( NumericScale AS NVARCHAR(50) ) + ')'
						ELSE ''
					END +
					CASE
						WHEN @DestinationSchema IN ('fact', 'bridge') AND inf.ColumnName LIKE '%Unique' THEN ' NOT NULL'
						ELSE ''
					END
		END AS TableLine,		
		CASE
			WHEN @DestinationSchema IN ('fact', 'bridge') AND ColumnName LIKE '%Identifier' THEN NULL /* Do not add identifier to view */ 
			WHEN @DestinationSchema IN ('fact', 'bridge') AND ColumnName LIKE '%' + @BusinessKeySuffix AND ColumnName NOT IN (SELECT ColumnName FROM #DimensionCombinedKeys) 
				THEN '[' + REPLACE( ColumnName, @BusinessKeySuffix, @SurrogatKeySuffix ) + ']'
			WHEN @DestinationSchema IN ('fact', 'bridge') AND ColumnName LIKE '%' + @BusinessKeySuffix AND ColumnName IN (SELECT ColumnName FROM #DimensionCombinedKeys) 
				THEN '[' + 	(SELECT DISTINCT DimensionTable FROM #DimensionCombinedKeys AS Dimension WHERE inf.ColumnName = Dimension.ColumnName)
					+ @SurrogatKeySuffix + ']'
			--If not the column is given an alias where the name is splited on upper characters
			WHEN (@DestinationSchema = 'dim' AND ColumnName NOT LIKE '%' + @SurrogatKeySuffix)
				THEN '[' + ColumnName + '] AS [' + ColumnName +']'
			ELSE '[' + ColumnName + ']'
		END AS ViewLine,
		inf.OrdinalPosition
	FROM #InformationSchema inf
	) q
GROUP BY TableLine, ViewLine
ORDER BY OrdinalPosition

SET IDENTITY_INSERT #CreateLines OFF

/**********************************************************************************************************************************************************************
Create audit column lines
***********************************************************************************************************************************************************************/

IF @DestinationSchema = 'dim'
BEGIN

	INSERT INTO #CreateLines (TableLine, ViewLine)
	VALUES 
		 ('[DWIsCurrent] BIT NOT NULL', '[DWIsCurrent]')
		,('[DWValidFromDate] DATETIME2(0) NOT NULL', '[DWValidFromDate]')
		,('[DWValidToDate] DATETIME2(0) NOT NULL', '[DWValidToDate]')
		,('[DWCreatedDate] DATETIME2(0) NOT NULL', '[DWCreatedDate]')
		,('[DWModifiedDate] DATETIME2(0) NOT NULL', '[DWModifiedDate]')
		,('[DWIsDeleted] BIT NOT NULL', '[DWIsDeleted]')

END 
ELSE
BEGIN

	INSERT INTO #CreateLines (TableLine, ViewLine)
	VALUES 
		 ('[DWCreatedDate] DATETIME2(0) NOT NULL', '[DWCreatedDate]')
		,('[DWModifiedDate] DATETIME2(0) NOT NULL', '[DWModifiedDate]')

END

/**********************************************************************************************************************************************************************
List key columns for dimension
***********************************************************************************************************************************************************************/
DECLARE @PrimaryDimensionKeyColumns NVARCHAR(MAX)

SELECT @PrimaryDimensionKeyColumns = STRING_AGG(ColumnName,',')
FROM #InformationSchema
WHERE IsPrimaryDimensionKey = 1

/**********************************************************************************************************************************************************************
Adding constraints to create scripts
***********************************************************************************************************************************************************************/

IF @LoadPattern = 'FactMerge' 
BEGIN

	INSERT INTO #CreateLines (CreateType, TableLine)
	SELECT 'FactTable', 'CONSTRAINT PK_' + DestinationTable + ' PRIMARY KEY NONCLUSTERED (' + ColumnName + ')'
	FROM #InformationSchema
	WHERE ColumnName LIKE '%Unique'

	INSERT INTO #CreateLines (CreateType, TableLine)
	SELECT 'FactTableTemp', 'CONSTRAINT PK_TEMP_' + DestinationTable + ' PRIMARY KEY NONCLUSTERED (' + ColumnName + ')' 
	FROM #InformationSchema
	WHERE ColumnName LIKE '%Unique'

END

IF @DestinationSchema IN ('dim')
BEGIN

	INSERT INTO #CreateLines (TableLine)
	SELECT 'CONSTRAINT NCI_' + @DestinationTable + ' UNIQUE NONCLUSTERED (' + @PrimaryDimensionKeyColumns + IIF(@Type2HistoryFromSourceKey = 1, ',' + @DestinationTable + 'ValidFromDate)',',DWValidFromDate)')

END



/**********************************************************************************************************************************************************************
Generate script for adding extended property for type 2 columns
***********************************************************************************************************************************************************************/
DECLARE @ExtendendPropertyType2Column NVARCHAR(MAX)

SELECT @ExtendendPropertyType2Column = STRING_AGG(CAST('EXEC sys.sp_addextendedproperty @name=N''HistoryType'', @value=N''Type2'' ,@level0type = N''Schema'', @level0name = ''dim'' ,@level1type = N''Table'',  @level1name = ''' + @DestinationTable + ''' ,@level2type = N''Column'', @level2name = ''' + ColumnName + '''' AS NVARCHAR(MAX)), @CRLF)
FROM #InformationSchema
WHERE IsType2 = 1

/**********************************************************************************************************************************************************************
Fill out the dynamic SQL script variables
***********************************************************************************************************************************************************************/

DECLARE @DropTableScript AS NVARCHAR(MAX)  
DECLARE @DropTempTableScript AS NVARCHAR(MAX) 
DECLARE @DropViewScript AS NVARCHAR(MAX)  
DECLARE @DropTempViewScript AS NVARCHAR(MAX)  
DECLARE @CreateTableScript AS NVARCHAR(MAX) 
DECLARE @CreateTempTableScript AS NVARCHAR(MAX)
DECLARE @DestinationTableLines NVARCHAR(MAX)
DECLARE @ViewLines NVARCHAR(MAX)
DECLARE @CreateClusteredColumnStoreIndexScript NVARCHAR(MAX)
DECLARE @PrepareViewScript AS NVARCHAR(MAX) 
DECLARE @CreateViewScript NVARCHAR(MAX) 
DECLARE @PrepareTempViewScript AS NVARCHAR(MAX) 
DECLARE @CreateTempViewScript NVARCHAR(MAX) 
DECLARE @CreateIncrementalProperty NVARCHAR(MAX)
DECLARE @SQL NVARCHAR(MAX)

SET @DropTableScript = 'DROP TABLE IF EXISTS [' + @DestinationSchema + '].[' + @DestinationTable + ']'
SET @DropTempTableScript = 'DROP TABLE IF EXISTS [' + @DestinationSchema + '].[' + @DestinationTable + '_Temp]'
SET @DropViewScript = 'DROP VIEW IF EXISTS [' + @DestinationSchema + 'View].[' + @ViewName + ']'
SET @DropTempViewScript = 'DROP VIEW IF EXISTS [' + @DestinationSchema + 'View].[' + @ViewName + '_Temp]'
SET @CreateClusteredColumnStoreIndexScript = 'CREATE CLUSTERED COLUMNSTORE INDEX [CCI_' + @DestinationTable + '] ON [' + @DestinationSchema + '].[' + @DestinationTable + '] WITH (DROP_EXISTING = OFF)'


/**********************************************************************************************************************************************************************
Generates the final create table script
***********************************************************************************************************************************************************************/

SELECT @DestinationTableLines = STRING_AGG(TableLine+@CRLF,',')
FROM #CreateLines
WHERE ISNULL(CreateType,'') <> 'FactTableTemp'

SET @DropTableScript = 'DROP TABLE IF EXISTS [' + @DestinationSchema + '].[' + @DestinationTable + ']'
SET @CreateTableScript = 'CREATE TABLE [' + @DestinationSchema + '].[' + @DestinationTable + ']
(
' + @DestinationTableLines + '
)'

SELECT @DestinationTableLines = STRING_AGG(TableLine+@CRLF,',')
FROM #CreateLines
WHERE ISNULL(CreateType,'') <> 'FactTable'

SET @CreateTempTableScript = '
CREATE TABLE [' + @DestinationSchema + '].[' + @DestinationTable + '_Temp]
(
' + @DestinationTableLines +
')'


/**********************************************************************************************************************************************************************
Generates the final create view script
***********************************************************************************************************************************************************************/

SELECT @ViewLines = STRING_AGG(ViewLine + @CRLF + CHAR(9),',')
FROM #CreateLines
WHERE ISNULL(CreateType,'') = ''

SET @PrepareViewScript = 'CREATE VIEW [' + @DestinationSchema + 'View].[' + @ViewName + '] 
AS
SELECT
	'+ @ViewLines + 
'
FROM [' + @DestinationSchema + '].[' + @DestinationTable + ']'

SET @CreateViewScript = 'EXEC(''' + @PrepareViewScript + ''')'


SET @PrepareTempViewScript = 'CREATE VIEW [' + @DestinationSchema + 'View].[' + @ViewName + '_Temp] 
AS
SELECT
	'+ @ViewLines +
'
FROM [' + @DestinationSchema + '].[' + @DestinationTable + '_Temp]'

SET @CreateTempViewScript = 'EXEC(''' + @PrepareTempViewScript + ''')'


/**********************************************************************************************************************************************************************
Create final script
***********************************************************************************************************************************************************************/

SET @SQL = 
	CONCAT(
		@DropViewScript, @CRLF,
		@DropTempViewScript, @CRLF,
		@DropTableScript, @CRLF,
		@DropTempTableScript, @CRLF,
		@CreateTableScript, @CRLF,
		@CreateViewScript, @CRLF,
		IIF(@LoadPattern LIKE 'Fact%',@CreateClusteredColumnStoreIndexScript,''), @CRLF,
		IIF(@LoadPattern LIKE 'Fact%',@CreateTempTableScript,''), @CRLF,
		ISNULL(@ExtendendPropertyType2Column, ''),@CRLF
		)

/**********************************************************************************************************************************************************************
Execute dynamic SQL
***********************************************************************************************************************************************************************/

IF @PrintSQL = 0
BEGIN
	
	EXEC (@SQL)

END
ELSE
BEGIN

	SELECT 
		CAST('<?SQL --'
			+@CRLF
			+ISNULL(@SQL,'')
			+@CRLF
			+ '-- ?>' AS XML) SQLScript

END

SET NOCOUNT OFF
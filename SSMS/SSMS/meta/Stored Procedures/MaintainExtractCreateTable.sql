



/**********************************************************************************************************************************************************************
The purpose of this scripts is to create the create table script for extract tables
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [meta].[MaintainExtractCreateTable] 

@SourceObjectID INT,--Input is the table name without schema
@DropTable BIT, --Input is 1 if you want the table to be dropped if it already exists
@PrintSQL BIT

AS

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/
DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10)
DECLARE @DatabaseNameExtract NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameExtract')
DECLARE @ExtractCCIFlag NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'ExtractCCIFlag')
DECLARE @ExtractCCIHistoryFlag NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'ExtractCCIHistoryFlag')
DECLARE @EnterpriseEditionFlag NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'EnterpriseEditionFlag')
DECLARE @SeparateHistoryFlag NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'SeparateHistoryLayerFlag')
DECLARE @NavisionFlag BIT = (SELECT DISTINCT NavisionFlag FROM meta.ExtractInformationSchemaDefinitions WHERE SourceObjectID = CAST(@SourceObjectID AS INT))
DECLARE @IsCloudFlag NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'IsCloudFlag')
DECLARE @Table NVARCHAR(128) = (SELECT DISTINCT TableName  FROM meta.ExtractInformationSchemaDefinitions WHERE SourceObjectID = CAST(@SourceObjectID AS INT))

/**********************************************************************************************************************************************************************
1. Create and insert data into table variables
**********************************************************************************************************************************************************************/
DECLARE @Schemas TABLE (SchemaName NVARCHAR(128), ExtractSchemaName NVARCHAR(128), OrdinalPosition INT)
DECLARE @InformationSchema TABLE (DatabaseName NVARCHAR(128), TableSchema NVARCHAR(128), TableName NVARCHAR(128), ColumnName NVARCHAR(128), OrdinalPosition INT, DataType NVARCHAR(128), Nullable NVARCHAR(128), KeySequence INT, HistoryFlag INT, TruncateFlag INT)

INSERT @InformationSchema SELECT DISTINCT   
									   ISNULL(TableCatalogName,'')
									  ,ISNULL(SchemaName,'')
									  ,TableName
									  ,ColumnName
									  ,ROW_NUMBER() OVER (PARTITION BY SchemaName, TableName ORDER BY OrdinalPositionNumber) AS OrdinalPositionNumber
									  ,FullDataTypeName
									  ,NullableName
									  ,KeySequenceNumber
									  ,PreserveHistoryFlag
									  ,TruncateBeforeDeployFlag
						FROM meta.ExtractInformationSchemaDefinitions AS MetaData
						WHERE MetaData.[SourceObjectID] = @SourceObjectID


						
INSERT @Schemas SELECT ISNULL(MetaData.SchemaName,''), MetaData.ExtractSchemaName,ROW_NUMBER() OVER (ORDER BY MetaData.ExtractSchemaName)
						FROM 
							meta.ExtractInformationSchemaDefinitions AS MetaData
						WHERE
							MetaData.SourceObjectID = @SourceObjectID
						GROUP BY ExtractSchemaName,SchemaName

						

/**********************************************************************************************************************************************************************
2. Create Loop counter variables
**********************************************************************************************************************************************************************/
DECLARE @Counter INT
DECLARE @MaxColumns INT 
DECLARE @InnerCounter INT
DECLARE @MaxSchemas INT

SELECT 
		@Counter = 1
	   ,@InnerCounter = 1
	   ,@MaxColumns = (SELECT MAX(OrdinalPosition) FROM @InformationSchema)
	   ,@MaxSchemas = (SELECT MAX(OrdinalPosition) FROM @Schemas)

/**********************************************************************************************************************************************************************
3. Create Table SQL
**********************************************************************************************************************************************************************/
DECLARE @PlaceholderTables NVARCHAR(MAX)
DECLARE @Tables NVARCHAR(MAX)
DECLARE @TableScript NVARCHAR(MAX)
DECLARE @Schema NVARCHAR(MAX)
DECLARE @ExtractSchema NVARCHAR(MAX)
DECLARE @PlaceholderPrimaryKeyColumns NVARCHAR(MAX)
DECLARE @PrimaryKeyColumns NVARCHAR(MAX)
DECLARE @HistoryFlag INT
DECLARE @SQLScriptDrop NVARCHAR(MAX)
DECLARE @SQLScriptCreate NVARCHAR(MAX)
DECLARE @ClusteredColumnStoreIndexScript NVARCHAR(MAX)
DECLARE @ClusteredColumnStoreIndexScriptHistory NVARCHAR(MAX)
DECLARE @HistoryTable NVARCHAR(100) = IIF(@SeparateHistoryFlag = 1,@Table,@Table + '_History')
DECLARE @HistorySchema NVARCHAR(50)
DECLARE @TruncateFlag BIT
DECLARE @TruncateProperty NVARCHAR(MAX)

WHILE @Counter <= @MaxSchemas

BEGIN

SELECT 
		@Schema = SchemaName,
		@ExtractSchema = ExtractSchemaName,
		@HistorySchema = IIF(@SeparateHistoryFlag = 1,ExtractSchemaName + '_history',ExtractSchemaName)
FROM @Schemas
WHERE @Counter = OrdinalPosition

SET @TruncateFlag = (SELECT DISTINCT TruncateFlag FROM @InformationSchema WHERE TableName = @Table AND TableSchema = @Schema)

	
	WHILE @InnerCounter <= @MaxColumns

	BEGIN

		SELECT 
			@PlaceholderTables = IIF(@InnerCounter = 1,'',',') + '[' + ColumnName + '] ' + DataType + ' ' + Nullable + @CRLF
		FROM @InformationSchema
		WHERE TableName = @Table
		AND OrdinalPosition = @InnerCounter
		AND TableSchema = @Schema

		SELECT 
			@PlaceholderPrimaryKeyColumns = IIF(KeySequence = 1,'',IIF(KeySequence IS NULL,'',',')) + IIF(KeySequence IS NULL,'','[' + ColumnName + ']')
		FROM @InformationSchema
		WHERE TableName = @Table
		AND KeySequence = @InnerCounter
		AND TableSchema = @Schema
		AND KeySequence IS NOT NULL
		ORDER BY KeySequence



SET @Tables = CONCAT(@Tables,@PlaceholderTables)

SET @PrimaryKeyColumns = CONCAT(@PrimaryKeyColumns,@PlaceholderPrimaryKeyColumns)

SET @PlaceholderTables = ''

SET @PlaceholderPrimaryKeyColumns = ''

SET @InnerCounter = @InnerCounter + 1

END

SET @HistoryFlag = (SELECT DISTINCT HistoryFlag FROM @InformationSchema WHERE TableName = @Table AND TableSchema = @Schema)


SET @SQLScriptDrop = IIF(@DropTable = 1,IIF(@IsCloudFLag = 1,'','USE ' + @DatabaseNameExtract + @CRLF) + ' IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id(''[' + @ExtractSchema + '].[' + @Table + ']''))
BEGIN
DROP TABLE ['+ @ExtractSchema + '].[' + @Table + ']
END ' +

IIF(@IsCloudFLag = 1,'','USE ' + @DatabaseNameExtract + @CRLF ) + ' IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id(''[' + @HistorySchema + '].[' + @HistoryTable + ']''))
BEGIN
DROP TABLE ['+ @HistorySchema + '].[' + @HistoryTable + ']
END','') + @CRLF

SET @SQLScriptCreate = IIF(@IsCloudFLag = 1,'','USE ' + @DatabaseNameExtract) + @CRLF + 
'IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id(''[' + @ExtractSchema + '].[' + @Table + ']''))
BEGIN
PRINT ''Table Exists''
END
ELSE
BEGIN
CREATE TABLE ['+ @ExtractSchema + '].[' + @Table + ']' + @CRLF + '(' + @Tables +',DWCreatedDate DATETIME DEFAULT (GETDATE()) ' + IIF(@NavisionFlag = 1,',DWNavisionCompany NVARCHAR(50)','') + @CRLF +
IIF(@PrimaryKeyColumns <> '','CONSTRAINT [PK_' + @Table + '] PRIMARY KEY NONCLUSTERED (' + @PrimaryKeyColumns + IIF(@NavisionFlag = 1,',DWNavisionCompany','') + ')) ' + @CRLF + 'END',') ' + @CRLF + 'END') 
+ @CRLF + @CRLF +
IIF( @HistoryFlag= 1,
'IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id(''[' + @HistorySchema + '].[' + @HistoryTable + ']''))
BEGIN
PRINT ''History Table Exists''
END
ELSE
BEGIN
CREATE TABLE ['+ @HistorySchema + '].[' + @HistoryTable + ']' + @CRLF + '(' + @Tables +'
,[DWIsCurrent] BIT
,[DWValidFromDate] DATETIME
,[DWValidToDate] DATETIME
,[DWCreatedDate] DATETIME
,[DWModifiedDate] DATETIME
,[DWIsDeletedInSource] BIT
,[DWDeletedInSourceDate] DATETIME' + IIF(@NavisionFlag = 1,',DWNavisionCompany NVARCHAR(50)','') + @CRLF +
IIF(@PrimaryKeyColumns <> '','CONSTRAINT [PK_' + @Table + '_History] PRIMARY KEY NONCLUSTERED (' + @PrimaryKeyColumns + ',DWValidFromDate' + IIF(@NavisionFlag = 1,',DWNavisionCompany','') + '))' + 'END',') END'),'')

SET @ClusteredColumnStoreIndexScript = IIF(@IsCloudFLag = 1,'','USE ' + @DatabaseNameExtract) + @CRLF + 'IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id(''' + @ExtractSchema + '.' + @Table + ''') AND NAME = ''CCI_'+ @Table + ''')' + @CRLF +
																							'BEGIN CREATE CLUSTERED COLUMNSTORE INDEX [CCI_' + @Table + '] ON ' + @ExtractSchema + '.[' + @Table + '] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0)
																							END'

SET @ClusteredColumnStoreIndexScriptHistory = IIF(@IsCloudFLag = 1,'','USE ' + @DatabaseNameExtract) + @CRLF + 'IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id(''' + @HistorySchema + '.' + @HistoryTable + ''') AND NAME = ''CCI_'+ @Table + '_History'')' + @CRLF +
																							'BEGIN CREATE CLUSTERED COLUMNSTORE INDEX [CCI_' + @Table + '_History] ON ' + @HistorySchema + '.[' + @HistoryTable + '] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0)
																							END'

SET @TruncateProperty = IIF(@TruncateFlag = 0,'','EXEC [' + @DatabaseNameExtract + '].sys.sp_addextendedproperty @name = N''TruncateBeforeDeploy'', @value = N''True'', @level0type = N''SCHEMA'', @level0name = N''' + @ExtractSchema + ''', @level1type = N''TABLE'', @level1name = N''' + @Table +'''' + @CRLF	)																						

IF @PrintSQL = 0

	BEGIN
		EXEC(@SQLScriptDrop)
		EXEC(@SQLScriptCreate)
		EXEC(@TruncateProperty)

		IF @ExtractCCIFlag = 1 AND @EnterpriseEditionFlag = 1
			BEGIN
				EXEC(@ClusteredColumnStoreIndexScript)
			END
		IF @HistoryFlag = 1 AND @ExtractCCIHistoryFlag = 1 AND @EnterpriseEditionFlag = 1
			BEGIN
				EXEC(@ClusteredColumnStoreIndexScriptHistory)
			END
	END

ELSE

	BEGIN
		PRINT(@SQLScriptDrop)
		PRINT(LEFT(@SQLScriptCreate,4000))
		PRINT(SUBSTRING(@SQLScriptCreate,4001,4000))
		PRINT(@TruncateProperty)

		IF @ExtractCCIFlag = 1
			BEGIN
				PRINT(@ClusteredColumnStoreIndexScript)
			END
		IF @HistoryFlag = 1 AND @ExtractCCIHistoryFlag = 1
			BEGIN
				PRINT(@ClusteredColumnStoreIndexScriptHistory)
			END
	END

SET @PrimaryKeyColumns = ''

SET @InnerCounter = 1

SET @Schema = ''

SET @ExtractSchema = ''

SET @Tables = ''

SET @Counter = @Counter + 1

END

SET NOCOUNT OFF
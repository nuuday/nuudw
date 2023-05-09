


/**********************************************************************************************************************************************************************
The purpose of this scripts is to create the create table script for extract tables
***********************************************************************************************************************************************************************/



CREATE PROCEDURE [meta].[MaintainTargetCreateTableScript] 

@TargetObjectID INT,
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


/**********************************************************************************************************************************************************************
1. Update FrameworkMetaData table with IDs
***********************************************************************************************************************************************************************/
INSERT INTO meta.FrameworkMetaData
(TargetObjectID)

SELECT 
	TargetObjects.ID 
FROM 
	meta.TargetObjects 
LEFT JOIN 
	meta.FrameworkMetaData 
		ON FrameworkMetaData.TargetObjectID = TargetObjects.ID 
WHERE 
	FrameworkMetaData.BusinessMatrixID IS NULL
	AND FrameworkMetaData.SourceObjectID IS NULL
	AND	FrameworkMetaData.TargetObjectID IS NULL
	AND TargetObjects.ID  = @TargetObjectID

DELETE FROM meta.FrameworkMetaData WHERE TargetObjectID NOT IN (SELECT ID FROM meta.TargetObjects) AND TargetObjectID IS NOT NULL;

/**********************************************************************************************************************************************************************
2. Create and insert data into table variables
**********************************************************************************************************************************************************************/
DECLARE @InformationSchemaTables TABLE (TargetObjectID INT, SchemaName NVARCHAR(128), ObjectName NVARCHAR(128), FileSystemName NVARCHAR(128),TargetConnectionName NVARCHAR(128), FolderName NVARCHAR(128), FileFormat NVARCHAR(128), FileExtension NVARCHAR(128), TargetAzureSqlDWFlag BIT, NavisionFlag BIT, OrdinalPosition INT)
INSERT @InformationSchemaTables SELECT TargetObjectID,TargetExtractSchemaName, SourceObjectName, TargetFileSystemName, TargetConnectionName, TargetFolderName, TargetAzureFileTypeName, TargetFileExtension, TargetAzureSqlDWFlag, SourceNavisionFlag, ROW_NUMBER() OVER ( ORDER BY TargetObjectID) FROM meta.TargetObjectDefinitions WHERE TargetObjectID = @TargetObjectID GROUP BY TargetObjectID,TargetExtractSchemaName, SourceObjectName,TargetFileSystemName,TargetConnectionName,TargetFolderName,TargetAzureFileTypeName,TargetAzureSqlDWFlag,SourceNavisionFlag,TargetFileExtension

/**********************************************************************************************************************************************************************
3. Create Loop counter variables
**********************************************************************************************************************************************************************/
DECLARE @OuterCounter INT = 1
DECLARE @MaxTable INT = (SELECT MAX(OrdinalPosition) FROM @InformationSchemaTables)


/**********************************************************************************************************************************************************************
4. Create outer loop
**********************************************************************************************************************************************************************/
DECLARE @Table NVARCHAR(100)
DECLARE @ExtractSchema NVARCHAR(100)
DECLARE @NavisionFlag BIT
DECLARE @AzureSQLDWFlag BIT
DECLARE @FileName NVARCHAR(128)
DECLARE @FileFormat NVARCHAR(128)
DECLARE @FileSystem NVARCHAR(128)
DECLARE @TargetConnectionName NVARCHAR(128)

WHILE @OuterCounter <= @MaxTable

BEGIN

	SELECT
	  @TargetObjectID = TargetObjectID
	 ,@Table = ObjectName
	 ,@ExtractSchema = SchemaName
	 ,@NavisionFlag = NavisionFlag
	 ,@AzureSQLDWFlag = TargetAzureSqlDWFlag
	 ,@FileName = IIF(FolderName = '','/','/' + FolderName +'/') + ObjectName + '.' + FileExtension
	 ,@FileFormat = FileFormat
	 ,@TargetConnectionName = TargetConnectionName
	 ,@FileSystem = FileSystemName
	FROM 
		@InformationSchemaTables
	WHERE 
		@OuterCounter = OrdinalPosition


/**********************************************************************************************************************************************************************
5. Create and insert data into table variables
**********************************************************************************************************************************************************************/
DECLARE @InformationSchema TABLE (SourceConnectionID INT, TableName NVARCHAR(128),ColumnName NVARCHAR(128), SchemaName NVARCHAR(128), OrdinalPosition INT,DataType NVARCHAR(128), CharacterMaximumLength NVARCHAR(128), NumericPrecisionNumber INT ,SourceSystem NVARCHAR(128), OriginalDataType NVARCHAR(128), KeySequence INT, HistoryFlag BIT)


INSERT @InformationSchema EXEC('WITH SourceData AS 
(SELECT 
   SourceConnectionID
  ,[TableName]
  ,MetaData.[ColumnName]
  ,[SchemaName]
  ,[OrdinalPositionNumber]
  ,[FullDataTypeName]
  ,[MaximumLenghtNumber]
  ,[NumericPrecisionNumber]
  ,[SourceSystemTypeName]
  ,IIF(TargetColumns.ColumnName IS NULL,0,1) AS TableHasColumnFilerFlag
  ,IIF(TargetColumns2.ColumnName IS NULL,0,1) AS ColumnFilerFlag
  ,[OriginalDataTypeName]
  ,[KeySequenceNumber]
  ,IncrementalFlag  
   FROM 
		meta.ExtractInformationSchemaDefinitions AS MetaData
   INNER JOIN
		meta.TargetObjects
			ON TargetObjects.SourceObjectID = MetaData.SourceObjectID
   LEFT JOIN
		meta.SourceColumns AS TargetColumns
			ON TargetObjects.SourceObjectID = TargetColumns.SourceObjectID
   LEFT JOIN
		meta.SourceColumns AS TargetColumns2
			ON MetaData.ColumnName = TargetColumns2.ColumnName
			AND TargetObjects.SourceObjectID = TargetColumns2.SourceObjectID 
   WHERE TargetObjects.ID = ''' + @TargetObjectID + ''' 
   AND MetaData.ColumnName <> ''DWCreatedDate'')

SELECT   
   SourceConnectionID
  ,[TableName]
  ,[ColumnName]
  ,[SchemaName]
  ,ROW_NUMBER() OVER (PARTITION BY SourceConnectionID,TableName ORDER BY [OrdinalPositionNumber]) AS [OrdinalPositionNumber]
  ,[FullDataTypeName]
  ,[MaximumLenghtNumber]
  ,[NumericPrecisionNumber]
  ,[SourceSystemTypeName]
  ,[OriginalDataTypeName]
  ,[KeySequenceNumber]
  ,IncrementalFlag
FROM SourceData
WHERE TableHasColumnFilerFlag = ColumnFilerFlag
GROUP BY SourceConnectionID
  ,[TableName]
  ,[ColumnName]
  ,[SchemaName]
  ,[FullDataTypeName]
  ,[MaximumLenghtNumber]
  ,[NumericPrecisionNumber]
  ,[SourceSystemTypeName]
  ,[OrdinalPositionNumber]
  ,[OriginalDataTypeName]
  ,[KeySequenceNumber]
  ,IncrementalFlag')



/**********************************************************************************************************************************************************************
2. Create Loop counter variables
**********************************************************************************************************************************************************************/
DECLARE @Counter INT
DECLARE @MaxColumns INT 

SELECT 
		@Counter = 1
	   ,@MaxColumns = (SELECT MAX(OrdinalPosition) FROM @InformationSchema)


/**********************************************************************************************************************************************************************
3. Create Table SQL
**********************************************************************************************************************************************************************/
DECLARE @PlaceholderColumns NVARCHAR(MAX)
DECLARE @Columns NVARCHAR(MAX)
DECLARE @TableScript NVARCHAR(MAX)
DECLARE @PlaceholderPrimaryKeyColumns NVARCHAR(MAX)
DECLARE @PrimaryKeyColumns NVARCHAR(MAX)
DECLARE @HistoryFlag INT
DECLARE @SQLScriptDrop NVARCHAR(MAX)
DECLARE @SQLScriptCreate NVARCHAR(MAX)
DECLARE @ClusteredColumnStoreIndexScript NVARCHAR(MAX)
DECLARE @ClusteredColumnStoreIndexScriptHistory NVARCHAR(MAX)
DECLARE @HistoryTable NVARCHAR(100) = IIF(@SeparateHistoryFlag = 1,@Table,@Table + '_History')
DECLARE @HistorySchema NVARCHAR(50) = IIF(@SeparateHistoryFlag = 1,@ExtractSchema + 'History',@ExtractSchema)
DECLARE @SQL NVARCHAR(MAX)

WHILE @Counter <= @MaxColumns

	BEGIN

			SELECT 
				 @PlaceholderColumns = IIF(@Counter = 1,'',',') + '[' + ColumnName + '] ' + CASE 
																								WHEN @AzureSQLDWFlag = 1 AND @FileFormat = 'DelimitedText' AND DataType <> 'varbinary' THEN 'NVARCHAR(500)'
																								WHEN @AzureSQLDWFlag = 1 AND @FileFormat = 'DelimitedText' AND DataType = 'varbinary' THEN 'NVARCHAR(MAX)'
																								WHEN @AzureSQLDWFlag = 1 AND @FileFormat <> 'DelimitedText' AND DataType = 'varbinary' THEN 'VARBINARY(MAX)'
																								WHEN @AzureSQLDWFlag = 1 AND DataType = 'UNIQUEIDENTIFIER' THEN 'NVARCHAR (128)'
																								ELSE DataType
																							END + ' NULL' + @CRLF 

			FROM @InformationSchema
			WHERE OrdinalPosition = @Counter


			SELECT 
				@PlaceholderPrimaryKeyColumns = IIF(KeySequence = 1,'',IIF(KeySequence IS NULL,'',',')) + IIF(KeySequence IS NULL,'','[' + ColumnName + ']')
			FROM @InformationSchema
			WHERE KeySequence = @Counter
			AND KeySequence IS NOT NULL
			ORDER BY KeySequence



		SET @Columns = CONCAT(@Columns,@PlaceholderColumns)

		SET @PrimaryKeyColumns = CONCAT(@PrimaryKeyColumns,@PlaceholderPrimaryKeyColumns)

		SET @PlaceholderColumns = ''

		SET @PlaceholderPrimaryKeyColumns = ''

		SET @Counter = @Counter + 1


	END

	SET @HistoryFlag = (SELECT DISTINCT HistoryFlag FROM @InformationSchema)
 
	SET @SQLScriptDrop =
	'
	IF object_id(''[' + @ExtractSchema + '].[' + @Table + ']'') IS NOT NULL
	BEGIN
		DROP ' + IIF(@AzureSQLDWFlag = 1,'EXTERNAL ','') + 'TABLE ['+ @ExtractSchema + '].[' + @Table + ']
	END '

	SET @SQLScriptCreate = 
	'BEGIN 
		CREATE ' + IIF(@AzureSQLDWFlag = 1,'EXTERNAL ','') + 'TABLE ['+ @ExtractSchema + '].[' + @Table + ']' + @CRLF + '(' + @Columns + IIF(@NavisionFlag = 1,',DWNavisionCompany NVARCHAR(50)','') + @CRLF +
	CASE 
		WHEN @PrimaryKeyColumns <> '' AND @AzureSQLDWFlag = 0 THEN 'CONSTRAINT [PK_' + @Table + '] PRIMARY KEY NONCLUSTERED (' + @PrimaryKeyColumns + IIF(@NavisionFlag = 1,',DWNavisionCompany','') + ') NOT ENFORCED) ' 
		WHEN @AzureSQLDWFlag = 1 THEN ') WITH (
												LOCATION=''' + @FileName + ''',
												DATA_SOURCE = ' + @TargetConnectionName + @FileSystem + ',
												FILE_FORMAT = ' + @FileFormat + 'Format
											)'
		ELSE ''
	END + @CRLF + 'END'
	+ @CRLF + @CRLF +
	IIF( @HistoryFlag= 1,
	'IF object_id(''[' + @HistorySchema + '].[' + @HistoryTable + ']'') IS NOT NULL
	BEGIN
		DROP TABLE ['+ @HistorySchema + '].[' + @HistoryTable + ']
	END
	BEGIN
	CREATE TABLE ['+ @HistorySchema + '].[' + @HistoryTable + ']' + @CRLF + '(' + @Columns +'
	,[DWIsCurrent] BIT
	,[DWValidFromDate] DATETIME
	,[DWValidToDate] DATETIME
	,[DWCreatedDate] DATETIME
	,[DWModifiedDate] DATETIME
	,[DWIsDeletedInSource] BIT
	,[DWDeletedInSourceDate] DATETIME' + IIF(@NavisionFlag = 1,',DWNavisionCompany NVARCHAR(50)','') + @CRLF +
	IIF(@PrimaryKeyColumns <> '' AND @AzureSQLDWFlag = 0,'CONSTRAINT [PK_' + @Table + '_History] PRIMARY KEY NONCLUSTERED (' + @PrimaryKeyColumns + ',DWValidFromDate' + IIF(@NavisionFlag = 1,',DWNavisionCompany','') + '))' + 'END',') END'),'')

	SET @ClusteredColumnStoreIndexScript =  'IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id(''' + @ExtractSchema + '.' + @Table + ''') AND NAME = ''CCI_'+ @Table + ''')' + @CRLF +
																							'BEGIN CREATE CLUSTERED COLUMNSTORE INDEX [CCI_' + @Table + '] ON ' + @ExtractSchema + '.[' + @Table + '] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0)
																							END'

	SET @ClusteredColumnStoreIndexScriptHistory =  'IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id(''' + @HistorySchema + '.' + @HistoryTable + ''') AND NAME = ''CCI_'+ @Table + '_History'')' + @CRLF +
																							'BEGIN CREATE CLUSTERED COLUMNSTORE INDEX [CCI_' + @Table + '_History] ON ' + @HistorySchema + '.[' + @HistoryTable + '] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0)
																							END'

	SET @SQL = CONCAT(@SQLScriptCreate,IIF(@ExtractCCIFlag = 1 AND @EnterpriseEditionFlag = 1 AND @AzureSQLDWFlag = 0,@ClusteredColumnStoreIndexScript,IIF(@HistoryFlag = 1 AND @ExtractCCIHistoryFlag = 1 AND @EnterpriseEditionFlag = 1 AND @AzureSQLDWFlag = 0,@ClusteredColumnStoreIndexScriptHistory,'')))
	
	IF @PrintSQL = 0
		BEGIN
			UPDATE meta.FrameworkMetaData
			SET CreateTableSQLScript = @SQL,
				DropTableSQLScript = @SQLScriptDrop
			WHERE
				TargetObjectID = @TargetObjectID
		END
	ELSE
		BEGIN
			PRINT(@SQL)
			PRINT(@SQLScriptDrop)
		END

	SET @PrimaryKeyColumns = ''

	SET @ExtractSchema = ''

	SET @Columns = ''

	SET @OuterCounter = @OuterCounter + 1

	DELETE FROM @InformationSchema

END

SET NOCOUNT OFF
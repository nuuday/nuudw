

/**********************************************************************************************************************************************************************
The purpose of this scripts is to create the source SQL for extract packages
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [meta].[MaintainTargetCreateConnectionScript] 

@TargetObjectID INT,
@PrintSQL BIT

AS

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/
DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10)
DECLARE @DatabaseNameExtract NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameExtract')
	
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
	AND TargetObjects.ID = @TargetObjectID

DELETE FROM meta.FrameworkMetaData WHERE TargetObjectID NOT IN (SELECT ID FROM meta.TargetObjects) AND TargetObjectID IS NOT NULL;

/**********************************************************************************************************************************************************************
2. Create and insert data into table variables
**********************************************************************************************************************************************************************/
DECLARE @InformationSchemaTables TABLE (TargetObjectID INT, FileSystemName NVARCHAR(128),TargetConnectionName NVARCHAR(128), FolderName NVARCHAR(128), FileFormat NVARCHAR(128), AzureDWSchemaName NVARCHAR(128), OrdinalPosition INT)
INSERT @InformationSchemaTables SELECT TargetObjectID,TargetFileSystemName, TargetConnectionName, TargetFolderName, TargetAzureFileTypeName, TargetExtractSchemaName,ROW_NUMBER() OVER ( ORDER BY TargetObjectID) FROM meta.TargetObjectDefinitions WHERE TargetObjectID = @TargetObjectID AND TargetAzureSqlDWFlag = 1 GROUP BY TargetObjectID,TargetFileSystemName,TargetConnectionName,TargetFolderName,TargetAzureFileTypeName,TargetExtractSchemaName

/**********************************************************************************************************************************************************************
3. Create Loop counter variables
**********************************************************************************************************************************************************************/
DECLARE @Counter INT = 1
DECLARE @MaxTable INT = (SELECT MAX(OrdinalPosition) FROM @InformationSchemaTables)


/**********************************************************************************************************************************************************************
4. Create outer loop
**********************************************************************************************************************************************************************/
DECLARE @SQL NVARCHAR(MAX)


WHILE @Counter <= @MaxTable

BEGIN

	SELECT
	  @TargetObjectID = TargetObjectID
	 ,@SQL = 'IF (SELECT [name] FROM [sys].[external_data_sources] WHERE [name] = ''' + TargetConnectionName + FileSystemName + ''') IS NULL' + @CRLF +   
					'CREATE EXTERNAL DATA SOURCE ' + TargetConnectionName + FileSystemName + '
					WITH (
						LOCATION=''abfss://' + LOWER(FileSystemName) + '@' + LOWER(TargetConnectionName) + '.dfs.core.windows.net'',
						CREDENTIAL = ' + TargetConnectionName  + ',
								TYPE = HADOOP
					);
			  IF (SELECT [name] FROM [sys].[schemas] WHERE [name] = ''' + AzureDWSchemaName + ''') IS NULL' + @CRLF +  '
			  EXEC(''CREATE SCHEMA ' + AzureDWSchemaName + ' AUTHORIZATION dbo'');
			  IF (SELECT [name] FROM [sys].[external_file_formats] WHERE [name] = ''' + FileFormat + 'Format'') IS NULL' + @CRLF +  '
			  EXEC(''' + CASE FileFormat
							WHEN 'DelimitedText' THEN 'CREATE EXTERNAL FILE FORMAT ' + FileFormat + 'Format WITH (FORMAT_TYPE = DELIMITEDTEXT, FORMAT_OPTIONS(FIELD_TERMINATOR = '''','''',STRING_DELIMITER = ''''\"'''',USE_TYPE_DEFAULT = True))'
							WHEN 'Parquet'		 THEN 'CREATE EXTERNAL FILE FORMAT ' + FileFormat + 'Format WITH (FORMAT_TYPE = PARQUET, DATA_COMPRESSION = ''''org.apache.hadoop.io.compress.SnappyCodec'''')'
							WHEN 'Orc'			 THEN 'CREATE EXTERNAL FILE FORMAT ' + FileFormat + 'Format WITH (FORMAT_TYPE = PARQUET, DATA_COMPRESSION = ''''org.apache.hadoop.io.compress.SnappyCodec'''')'
							ELSE ''
						 END + ''')'

	FROM 
	@InformationSchemaTables
	WHERE 
	@Counter = OrdinalPosition

/**********************************************************************************************************************************************************************
8. Update FrameworkMetaDate
**********************************************************************************************************************************************************************/
IF @PrintSQL = 0
	BEGIN
		UPDATE FrameworkMetaData
		SET ConnectionSQLScript = @SQL
		FROM meta.FrameworkMetaData
		WHERE TargetObjectID = @TargetObjectID
	END
ELSE
	BEGIN
		PRINT(@SQL)
	END

	SET @SQL = '' 
	SET @Counter = @Counter + 1

END

SET NOCOUNT OFF
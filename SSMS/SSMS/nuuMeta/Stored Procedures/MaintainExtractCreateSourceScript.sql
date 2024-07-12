


/**********************************************************************************************************************************************************************
The purpose of this scripts is to create the source SQL for extract pipelines
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [nuuMeta].[MaintainExtractCreateSourceScript] 
	@SourceObjectID INT,
	@PrintSQL BIT = 0
AS

SET NOCOUNT ON

/*
DECLARE @SourceObjectID INT = 1566
DECLARE @PrintSQL BIT = 1
--*/


DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10)
DECLARE @Catalog NVARCHAR(MAX)
DECLARE @Schema NVARCHAR(MAX)
DECLARE @Table NVARCHAR(50)  
DECLARE @Columns NVARCHAR(MAX)
DECLARE @DelimitedIdentifier NVARCHAR(30)
DECLARE @SQLScript NVARCHAR(MAX)
DECLARE @SQLLastValue NVARCHAR(MAX)
DECLARE @SQLSchema NVARCHAR(MAX)
DECLARE @WatermarkIsDate bit
DECLARE @Environment NVARCHAR(30)

SELECT
	@Catalog = SourceCatalogName,
	@Schema = SourceSchemaName,
	@Table = SourceObjectName,
	@DelimitedIdentifier = DelimitedIdentifier,
	@WatermarkIsDate = WatermarkIsDate,
	@Environment = Environment
FROM nuuMetaView.SourceObjectDefinitions
WHERE
	SourceObjectID = @SourceObjectID

SELECT 
	@Columns = STRING_AGG( 
								CASE 
									WHEN [OriginalDataTypeName] LIKE ('struct%') THEN 'to_json([' + ColumnName + ']) [' + ColumnName + '] ' 
									WHEN [OriginalDataTypeName] LIKE ('variant%') THEN 'to_json([' + ColumnName + ']) [' + ColumnName + '] ' 
									WHEN [OriginalDataTypeName] LIKE ('array%') THEN 'to_json([' + ColumnName + ']) [' + ColumnName + '] ' 
									--WHEN [OriginalDataTypeName] IN ('map<string,string>') THEN 'to_json([' + ColumnName + ']) [' + ColumnName + '] ' 
									WHEN [OriginalDataTypeName] IN ('map_attribute') THEN 'CAST(' + Extended.SourceColumn+'.' + Extended.SourceColumnAttribute + ' AS STRING) AS [' + ColumnName + '] ' 
									ELSE '[' + ColumnName + '] ' 
								END
								+ 
								CASE 
									WHEN LEFT(ColumnName,2) = 'DW' THEN 'AS [SRC_' + ColumnName + ']' 
									ELSE '' 
								END  
								+ 
								@CRLF
								, ','
								) WITHIN GROUP (ORDER BY OrdinalPositionNumber)
FROM nuuMetaView.[SourceInformationSchemaDefinitions] AS MetaData
LEFT JOIN nuuMeta.SourceObjectExtendedAttributes AS Extended	
	ON Extended.SourceObjectID = MetaData.SourceObjectID 
		AND Extended.DestinationColumn = MetaData.ColumnName
WHERE
	MetaData.[SourceObjectID] = @SourceObjectID


SET @SQLLastValue =
	CASE
		WHEN @WatermarkIsDate = 1 THEN 'convert(datetime, stuff(stuff(stuff(''@{activity(''Lookup_Last_Value_Loaded'').output.firstRow.LastValueLoaded}'', 9, 0, '' ''), 12, 0, '':''), 15, 0, '':''))'
		ELSE '''@{activity(''Lookup_Last_Value_Loaded'').output.firstRow.LastValueLoaded}'''	
	END 

SET @SQLSchema = 
	CASE
		WHEN ISNULL(@Environment,'') <> '' THEN '@{activity(''Lookup_Source_Schema_Name'').output.firstRow.SourceSchemaName}'
		ELSE @Schema
	END

SELECT
	@SQLScript = '
SELECT 
' + @Columns + + ' 
FROM ' + @Catalog + IIF( @Catalog = '', '', '.' ) + @SQLSchema + IIF( @SQLSchema = '', '', '.' ) + '[' + @Table + ']
' +
	CASE
		WHEN NULLIF(WatermarkColumnName,'') IS NULL THEN IIF(ExtractSQLFilter <> '', 'WHERE '+ExtractSQLFilter, '')
		WHEN LEFT(WatermarkColumnName,6) = 'SRC_DW' THEN ' WHERE ' + IIF(ExtractSQLFilter <> '', ExtractSQLFilter + ' AND ', '') + RIGHT(WatermarkColumnName,LEN(WatermarkColumnName)-4) + ' > ' + @SQLLastValue
		ELSE ' WHERE ' + IIF(ExtractSQLFilter <> '', ExtractSQLFilter + ' AND ', '') + WatermarkColumnName + ' > ' + @SQLLastValue		
	END
FROM nuuMetaView.SourceObjectDefinitions
WHERE
	SourceObjectID = @SourceObjectID

SET @SQLScript =
	CASE 
		WHEN @DelimitedIdentifier = 'Backtick' THEN TRANSLATE(@SQLScript,'[]','``')
		WHEN @DelimitedIdentifier = 'None' THEN REPLACE(REPLACE(@SQLScript,'[',''),']','')
		ELSE @SQLScript
	END 
	
-- Register databricks map data type with <" "> and converting them back to square brackets
--SET @SQLScript = REPLACE(@SQLScript,'<\"','[\"')
--SET @SQLScript = REPLACE(@SQLScript,'"\>','\"]')

IF @PrintSQL = 0
BEGIN

	UPDATE nuuMeta.SourceObject
	SET SourceQuery = @SQLScript /* Only update query if it is empty */
	WHERE ID = @SourceObjectID

END
ELSE
BEGIN

	SELECT 
	CAST('<?SQL --'
		+@CRLF
		+ISNULL(@SQLScript,'')
		+@CRLF
		+ '-- ?>' AS XML) SQLScript

END
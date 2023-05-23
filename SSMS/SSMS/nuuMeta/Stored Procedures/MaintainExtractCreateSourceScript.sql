


/**********************************************************************************************************************************************************************
The purpose of this scripts is to create the source SQL for extract pipelines
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [nuuMeta].[MaintainExtractCreateSourceScript] 
	@SourceObjectID INT,
	@PrintSQL BIT = 0
AS

SET NOCOUNT ON

/*
DECLARE @SourceObjectID INT = 1004
DECLARE @PrintSQL BIT = 0
--*/


DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10)
DECLARE @Schema NVARCHAR(MAX)
DECLARE @Table NVARCHAR(50)  
DECLARE @Columns NVARCHAR(MAX)
DECLARE @DelimitedIdentifier NVARCHAR(30)
DECLARE @SQLScript NVARCHAR(MAX)

SELECT
	@Schema = SourceSchemaName,
	@Table = SourceObjectName,
	@DelimitedIdentifier = DelimitedIdentifier
FROM nuuMetaView.SourceObjectDefinitions
WHERE
	SourceObjectID = @SourceObjectID

SELECT 
	@Columns = STRING_AGG('[' + ColumnName + '] ' + CASE WHEN LEFT(ColumnName,2) = 'DW' THEN 'AS [SRC_' + ColumnName + ']' ELSE '' END  + @CRLF, ',') WITHIN GROUP (ORDER BY OrdinalPositionNumber)
FROM nuuMetaView.[SourceInformationSchemaDefinitions] AS MetaData
WHERE
	MetaData.[SourceObjectID] = @SourceObjectID


SELECT
	@SQLScript = '
SELECT 
' + @Columns + + ' 
FROM ' + @Schema + IIF( @Schema = '', '', '.' ) + '[' + @Table + ']
' +
	CASE
		WHEN WatermarkColumnName IS NULL THEN IIF(ExtractSQLFilter <> '', 'WHERE '+ExtractSQLFilter, '')
		WHEN LEFT(WatermarkColumnName,6) = 'SRC_DW' THEN ' WHERE ' + IIF(ExtractSQLFilter <> '', ExtractSQLFilter + ' AND ', '') + RIGHT(WatermarkColumnName,LEN(WatermarkColumnName)-4) + ' > ' + '''@{activity(''Lookup_Last_Value_Loaded'').output.firstRow.LastValueLoaded}'''	
		ELSE ' WHERE ' + IIF(ExtractSQLFilter <> '', ExtractSQLFilter + ' AND ', '') + WatermarkColumnName + ' > ' + '''@{activity(''Lookup_Last_Value_Loaded'').output.firstRow.LastValueLoaded}'''			
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
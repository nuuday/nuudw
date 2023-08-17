﻿


/**********************************************************************************************************************************************************************
The purpose of this scripts is to create the source SQL for extract pipelines
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [nuuMeta].[MaintainExtractCreateSourceScript] 
	@SourceObjectID INT,
	@PrintSQL BIT = 0
AS

SET NOCOUNT ON

/*
DECLARE @SourceObjectID INT = 177
DECLARE @PrintSQL BIT = 1
--*/


DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10)
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
	@Schema = SourceSchemaName,
	@Table = SourceObjectName,
	@DelimitedIdentifier = DelimitedIdentifier,
	@WatermarkIsDate = WatermarkIsDate,
	@Environment = Environment
FROM nuuMetaView.SourceObjectDefinitions
WHERE
	SourceObjectID = @SourceObjectID

SELECT 
	@Columns = STRING_AGG('[' + ColumnName + '] ' + CASE WHEN LEFT(ColumnName,2) = 'DW' THEN 'AS [SRC_' + ColumnName + ']' ELSE '' END  + @CRLF, ',') WITHIN GROUP (ORDER BY OrdinalPositionNumber)
FROM nuuMetaView.[SourceInformationSchemaDefinitions] AS MetaData
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
FROM ' + @SQLSchema + IIF( @SQLSchema = '', '', '.' ) + '[' + @Table + ']
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
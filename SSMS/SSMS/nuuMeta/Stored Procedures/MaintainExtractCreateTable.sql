



/**********************************************************************************************************************************************************************
The purpose of this scripts is to create the create table script for extract tables
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [nuuMeta].[MaintainExtractCreateTable] 
	@SourceObjectID INT,--Input is the table name without schema
	@PrintSQL BIT = 0
AS

/*
DECLARE @SourceObjectID INT = 1004
DECLARE @PrintSQL BIT = 0
--*/

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/
DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10)
DECLARE @Table NVARCHAR(128)
DECLARE @CreateColumns NVARCHAR(MAX)
DECLARE @SelectColumns NVARCHAR(MAX)
DECLARE @DestinationSchema NVARCHAR(MAX)
DECLARE @PrimaryKeyColumns NVARCHAR(MAX)
DECLARE @SQLDrop NVARCHAR(MAX)
DECLARE @SQLTableContraint NVARCHAR(MAX)
DECLARE @SQLTableContraintHistory NVARCHAR(MAX)
DECLARE @SQLCreate NVARCHAR(MAX)
DECLARE @SQLCreateHistory NVARCHAR(MAX)
DECLARE @SQLCreateHistoryView NVARCHAR(MAX)
DECLARE @ClusteredColumnStoreIndexScript NVARCHAR(MAX)
DECLARE @ClusteredColumnStoreIndexScriptHistory NVARCHAR(MAX)
DECLARE @HistoryTable NVARCHAR(100)
DECLARE @HistoryFlag INT

SELECT 
	@HistoryFlag = PreserveHistoryFlag,
	@DestinationSchema = DestinationSchemaName,
	@Table = SourceObjectName,
	@HistoryTable = SourceObjectName + '_History'
FROM nuuMetaView.SourceObjectDefinitions
WHERE SourceObjectID = @SourceObjectID


/**********************************************************************************************************************************************************************
Prepare SQL
**********************************************************************************************************************************************************************/
	
-- Get list of all columns in correct order
SELECT 
	@CreateColumns = STRING_AGG(cast(@CRLF+CHAR(9)+'[' + CASE WHEN LEFT(ColumnName,2) = 'DW' THEN 'SRC_' ELSE '' END + ColumnName + '] ' + FullDataTypeName + ' ' + NullableName as nvarchar(max)), ',') WITHIN GROUP (ORDER BY OrdinalPositionNumber),
	@SelectColumns = STRING_AGG(cast(@CRLF+CHAR(9)+'[' + CASE WHEN LEFT(ColumnName,2) = 'DW' THEN 'SRC_' ELSE '' END + ColumnName + '] ' as nvarchar(max)), ',') WITHIN GROUP (ORDER BY OrdinalPositionNumber)
FROM nuuMetaView.SourceInformationSchemaDefinitions AS MetaData
WHERE
	MetaData.[SourceObjectID] = @SourceObjectID


-- Get list of all primary columns in correct order
SELECT 
	@PrimaryKeyColumns = STRING_AGG('[' +  CASE WHEN LEFT(ColumnName,2) = 'DW' THEN 'SRC_' ELSE '' END + ColumnName + ']', ',') WITHIN GROUP (ORDER BY KeySequenceNumber)
FROM nuuMetaView.SourceInformationSchemaDefinitions AS MetaData
WHERE
	MetaData.[SourceObjectID] = @SourceObjectID
	AND KeySequenceNumber IS NOT NULL


SET @SQLTableContraint = IIF(@PrimaryKeyColumns <> '','CONSTRAINT [PK_' + @Table + '] PRIMARY KEY NONCLUSTERED (' + @PrimaryKeyColumns + ')','')
SET @SQLTableContraintHistory = IIF(@PrimaryKeyColumns <> '','CONSTRAINT [PK_' + @Table + '_History] PRIMARY KEY NONCLUSTERED (' + @PrimaryKeyColumns + ',DWValidFromDate' + ')','')

SET @SQLDrop = '
DROP TABLE IF EXISTS ['+ @DestinationSchema + '].[' + @Table + ']
DROP TABLE IF EXISTS ['+ @DestinationSchema + '].[' + @HistoryTable + ']
DROP VIEW IF EXISTS ['+ @DestinationSchema + 'View].[' + @HistoryTable + ']

'

SET @SQLCreate = '
CREATE TABLE ['+ @DestinationSchema + '].[' + @Table + '] (' + @CreateColumns +'
	,DWCreatedDate DATETIME2(7) DEFAULT (GETDATE()) 
	' + @SQLTableContraint + '
) 
'

SET @SQLCreateHistory = IIF( @HistoryFlag= 1,'
CREATE TABLE ['+ @DestinationSchema + '].[' + @HistoryTable + '] (' + @CreateColumns +'
	,[DWIsCurrent] BIT
	,[DWValidFromDate] DATETIME2(7)
	,[DWValidToDate] DATETIME2(7)
	,[DWCreatedDate] DATETIME2(7)
	,[DWModifiedDate] DATETIME2(7)
	,[DWIsDeletedInSource] BIT
	,[DWDeletedInSourceDate] DATETIME2(7)
' + @SQLTableContraintHistory + '
)','')

SET @SQLCreateHistoryView = IIF( @HistoryFlag= 1,'
CREATE VIEW ['+ @DestinationSchema + 'View].[' + @HistoryTable + ']
AS
SELECT ' + @SelectColumns +'
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM ['+ @DestinationSchema + '].[' + @HistoryTable + ']
WHERE DWIsCurrent = 1
','')
	
SET @ClusteredColumnStoreIndexScript =  '
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_' + @Table + '] ON ' + @DestinationSchema + '.[' + @Table + '] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0)
'

SET @ClusteredColumnStoreIndexScriptHistory = IIF( @HistoryFlag= 1,'
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_' + @Table + '_History] ON ' + @DestinationSchema + '.[' + @HistoryTable + '] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0)
','')

/**********************************************************************************************************************************************************************
Exectute SQL
**********************************************************************************************************************************************************************/

IF @PrintSQL = 0
BEGIN

	EXEC(@SQLDrop)
	EXEC(@SQLCreate)
	EXEC(@SQLCreateHistory)
	EXEC(@SQLCreateHistoryView)
	EXEC(@ClusteredColumnStoreIndexScript)
	EXEC(@ClusteredColumnStoreIndexScriptHistory)

END
ELSE
BEGIN

	SELECT 
		CAST('<?SQL --'
			+@CRLF
			+ISNULL(@SQLDrop,'')
			+ISNULL(@SQLCreate,'')
			+ISNULL(@SQLCreateHistory,'')
			+ISNULL(@SQLCreateHistoryView,'')
			+ISNULL(@ClusteredColumnStoreIndexScript,'')
			+ISNULL(@ClusteredColumnStoreIndexScriptHistory,'')
			+@CRLF
			+ '-- ?>' AS XML) SQLScript

END

SET NOCOUNT OFF
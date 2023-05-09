

/**********************************************************************************************************************************************************************
The purpose of this scripts is to update meta data information schema table based on Get Metadata activity in ADF
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [meta].[MaintainExtractInformationSchemaFromJsonMeta] 
@SourceObjectID int, -- SourceObjectID
@JsonOutput NVARCHAR(MAX)--Json output from ADF Get Meta Data activity

AS

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/
DECLARE @CRLF NVARCHAR(2) = CHAR(13) + CHAR(10)
DECLARE @ConnectionType NVARCHAR(128) = (SELECT ConnectionType FROM [meta].[SourceObjectDefinitions] WHERE SourceObjectID = @SourceObjectID)
DECLARE @FileName NVARCHAR(128) = (SELECT FileName FROM [meta].[SourceObjectDefinitions] WHERE SourceObjectID = @SourceObjectID)

/**********************************************************************************************************************************************************************
1. Update ExtractInformationSchema table
**********************************************************************************************************************************************************************/

DELETE FROM meta.ExtractInformationSchema WHERE SourceObjectID= @SourceObjectID;

INSERT INTO meta.ExtractInformationSchema
(
	[SourceObjectID], 
	[SourceSystemTypeName], 
	[TableCatalogName], 
	[SchemaName], 
	[TableName], 
	[ColumnName], 
	[OrdinalPositionNumber], 
	[DataTypeName], 
	[MaximumLenghtNumber], 
	[NumericPrecisionNumber], 
	[NumericScaleNumber], 
	[KeySequenceNumber]
)

SELECT
	@SourceObjectID			AS SourceObjectID
	,@ConnectionType		AS SourceSystemTypeName
	,null					AS TableCatalogName
	,null					AS SchemaName
	,@FileName				AS TableName
    ,SourceItems.name		AS ColumnName
	,ROW_NUMBER() OVER (PARTITION BY SourceHeader.itemName, SourceHeader.itemType ORDER BY (SELECT NULL))
							AS OrdinalPositionNumber
	,SourceItems.type		AS DataTypeName
	,null					AS MaximumLenghtNumber
	,null					AS NumericPrecisionNumber
	,null					AS NumericScaleNumber
	,null					AS KeySequenceNumber   
FROM OPENJSON(@JsonOutput)
WITH(
	itemName  varchar(200),
    itemType  varchar(200),  
    structure nvarchar(max) '$.structure' AS JSON
) SourceHeader
CROSS APPLY OPENJSON(SourceHeader.structure)
WITH(name nvarchar(200)
    ,type nvarchar(200)) SourceItems

SET NOCOUNT OFF

CREATE PROCEDURE [meta].[ViewTableProperties]

 @Table NVARCHAR(100)
,@SchemaName NVARCHAR(100)

AS

SET NOCOUNT ON

DECLARE @DatabaseNameDW NVARCHAR(50) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameDW')

EXEC('SELECT DISTINCT
		tables.name AS TableName
	,IIF(TableProperties.name = ColumnProperties.name,NULL, TableProperties.name) AS TableProperties
	,IIF(TableProperties.name = ColumnProperties.name,NULL, TableProperties.value) AS TablePropertiesValue
	,IIF(TableProperties.name <> ColumnProperties.name,NULL, all_columns.name) AS ColumnName
	,IIF(TableProperties.name <> ColumnProperties.name,NULL, ColumnProperties.name) AS ColumnProperties
	

FROM
	' + @DatabaseNameDW + '.sys.tables	
INNER JOIN
	' + @DatabaseNameDW + '.sys.schemas
		ON 	schemas	.schema_id = tables.schema_id					
INNER JOIN 
	' + @DatabaseNameDW + '.sys.all_columns 
		ON all_columns.object_id=tables.object_id
LEFT JOIN 
	' + @DatabaseNameDW + '.sys.extended_properties AS ColumnProperties
		ON ColumnProperties.major_id=tables.object_id 
		AND ColumnProperties.minor_id=all_columns.column_id 
		AND ColumnProperties.class=1
LEFT JOIN 
	' + @DatabaseNameDW + '.sys.extended_properties AS TableProperties
		ON TableProperties.major_id=tables.object_id 										
		AND TableProperties.class=1
WHERE
	tables.name = ''' + @Table + '''
	AND schemas.name = ''' + @SchemaName + '''')

SET NOCOUNT OFF
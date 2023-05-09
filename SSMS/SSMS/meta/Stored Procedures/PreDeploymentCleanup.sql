
CREATE PROCEDURE [meta].[PreDeploymentCleanup]

AS

SET NOCOUNT ON


/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.	
 Use SQLCMD syntax to include a file in the pre-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

DECLARE @DatabaseNameStage NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameStage')
DECLARE @DatabaseNameExtract NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameExtract')
DECLARE @DatabaseNameDW NVARCHAR(128) = (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameDW')

DECLARE @TruncateObjects TABLE (TableName NVARCHAR(128),SqlStatement NVARCHAR(MAX))

INSERT @TruncateObjects 

EXEC(
'SELECT 
	''[' + @DatabaseNameExtract + '].['' + s.[name] + ''].['' + t.[name] + '']'' AS SchemaTableName,
	''TRUNCATE TABLE [' + @DatabaseNameExtract + '].['' + s.[name] + ''].['' + t.[name] + ''];'' AS TruncateScript
FROM 
	[' + @DatabaseNameExtract + '].sys.[extended_properties] AS ep
	INNER JOIN [' + @DatabaseNameExtract + '].sys.[tables] AS [t] ON ep.[major_id] = t.[object_id]
	INNER JOIN [' + @DatabaseNameExtract + '].sys.[schemas] AS [s] ON [s].[schema_id] = [t].[schema_id]
WHERE 
	ep.[class_desc] = ''OBJECT_OR_COLUMN''
	AND ep.[name] = ''TruncateBeforeDeploy''

UNION

SELECT 
	''[' + @DatabaseNameDW + '].['' + s.[name] + ''].['' + t.[name] + '']'' AS SchemaTableName,
	''TRUNCATE TABLE [' + @DatabaseNameDW + '].['' + s.[name] + ''].['' + t.[name] + ''];'' AS TruncateScript
FROM 
	[' + @DatabaseNameDW + '].sys.[extended_properties] AS ep
	INNER JOIN [' + @DatabaseNameDW + '].sys.[tables] AS [t] ON ep.[major_id] = t.[object_id]
	INNER JOIN [' + @DatabaseNameDW + '].sys.[schemas] AS [s] ON [s].[schema_id] = [t].[schema_id]
WHERE 
	ep.[class_desc] = ''OBJECT_OR_COLUMN''
	AND ep.[name] = ''TruncateBeforeDeploy''

UNION

SELECT 
	''[' + @DatabaseNameStage + '].['' + TABLE_SCHEMA + ''].['' + TABLE_NAME + '']'' AS SchemaTableName,
	''TRUNCATE TABLE [' + @DatabaseNameStage + '].['' + TABLE_SCHEMA + ''].['' + TABLE_NAME + ''];'' AS TruncateScript
FROM 
	[' + @DatabaseNameStage + '].INFORMATION_SCHEMA.TABLES
WHERE
	TABLE_SCHEMA IN (''stage'',''stage_temp'')')


-- Declare variables
DECLARE @sql NVARCHAR(MAX) = '';

-- Truncate tables before deployment to save time
SET @sql = '';

SELECT 
	@sql += SqlStatement
FROM
	@TruncateObjects

EXEC sp_executesql @sql;

SET NOCOUNT OFF
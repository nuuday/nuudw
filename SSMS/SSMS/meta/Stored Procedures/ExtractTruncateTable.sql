CREATE PROCEDURE [meta].[ExtractTruncateTable]

 @TableName NVARCHAR(128)
,@ExtractSchemaName NVARCHAR(100)

AS

SET NOCOUNT ON

EXEC('TRUNCATE TABLE [' + @ExtractSchemaName + '].[' + @TableName + ']')

SET NOCOUNT OFF
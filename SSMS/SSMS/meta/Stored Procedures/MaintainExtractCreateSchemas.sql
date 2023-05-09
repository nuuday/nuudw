
CREATE PROCEDURE [meta].[MaintainExtractCreateSchemas]

@ExtractSchemaName NVARCHAR(100),
@PrintSQL BIT

AS

/**********************************************************************************************************************************************************************
1. Create Schemas
**********************************************************************************************************************************************************************/
DECLARE @ExtractHistorySchemas NVARCHAR(50) = @ExtractSchemaName + '_history'
DECLARE @CreateSchemasSQL NVARCHAR(MAX)
DECLARE @CreateHistorySchemasSQL NVARCHAR(MAX)

SET @CreateSchemasSQL = 'CREATE SCHEMA ' + @ExtractSchemaName
SET @CreateHistorySchemasSQL = 'CREATE SCHEMA ' + @ExtractHistorySchemas

IF @PrintSQL = 0

	BEGIN 
		IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = @ExtractSchemaName)
			BEGIN 
				EXEC(@CreateSchemasSQL)
			END
		IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = @ExtractHistorySchemas)
			BEGIN 
				EXEC(@CreateHistorySchemasSQL)
			END
	END
ELSE
	BEGIN
		IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = @ExtractSchemaName)
			BEGIN 
				PRINT(@CreateSchemasSQL)
			END
		IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = @ExtractHistorySchemas)
			BEGIN 
				PRINT(@CreateHistorySchemasSQL)
			END
	END
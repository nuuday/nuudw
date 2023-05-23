
CREATE PROCEDURE [nuuMeta].[MaintainExtractCreateSchemas]

@ExtractSchemaName NVARCHAR(50),
@PrintSQL BIT

AS

/**********************************************************************************************************************************************************************
1. Create Schemas
**********************************************************************************************************************************************************************/

DECLARE @ExtractSchemaView NVARCHAR(50) = @ExtractSchemaName + 'View'
DECLARE @CreateSchemasSQL NVARCHAR(MAX)
DECLARE @CreateViewSchemasSQL NVARCHAR(MAX)

SET @CreateSchemasSQL = 'CREATE SCHEMA ' + @ExtractSchemaName
SET @CreateViewSchemasSQL = 'CREATE SCHEMA ' + @ExtractSchemaView

IF @PrintSQL = 0

	BEGIN 
		IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = @ExtractSchemaName)
			BEGIN 
				EXEC(@CreateSchemasSQL)
			END
		IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = @ExtractSchemaView)
			BEGIN 
				EXEC(@CreateViewSchemasSQL)
			END
	END
ELSE
	BEGIN
		IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = @ExtractSchemaName)
			BEGIN 
				PRINT(@CreateSchemasSQL)
			END
		IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = @ExtractSchemaView)
			BEGIN 
				PRINT(@CreateViewSchemasSQL)
			END
	END
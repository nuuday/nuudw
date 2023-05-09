
CREATE PROCEDURE [meta].[MaintainExtract]

@SourceObjectID INT ,
@DropTable BIT

AS

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
1. Create Extract Tables
**********************************************************************************************************************************************************************/
DECLARE @ExecuteCreateTable NVARCHAR(MAX)
DECLARE @ExecuteCreateSourceScript NVARCHAR(MAX)
DECLARE @ExecuteCreatePartitionScript NVARCHAR(MAX)


SELECT 
	 @ExecuteCreateTable = 'EXECUTE meta.[MaintainExtractCreateTable] @SourceObjectID = ''' + CAST(@SourceObjectID AS NVARCHAR(20))+ ''', @DropTable = ' + CAST(@DropTable AS NVARCHAR(1)) + ', @PrintSQL = 0'
	,@ExecuteCreateSourceScript = 'EXECUTE meta.[MaintainExtractCreateSourceScript] @SourceObjectID = ''' + CAST(@SourceObjectID AS NVARCHAR(20)) + '''' + ', @PrintSQL = 0'
	,@ExecuteCreatePartitionScript = 'EXECUTE meta.[MaintainExtractCreatePartitionScript] @SourceObjectID = ''' + CAST(@SourceObjectID AS NVARCHAR(20)) + '''' + ', @PrintSQL = 0'

EXEC(@ExecuteCreateTable)
EXEC(@ExecuteCreateSourceScript)
EXEC(@ExecuteCreatePartitionScript)


SET NOCOUNT OFF
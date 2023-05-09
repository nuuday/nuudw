

CREATE PROCEDURE [meta].[MaintainTarget]

@TargetObjectID INT

AS

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
1. Create Extract Tables
**********************************************************************************************************************************************************************/
DECLARE @ExecuteCreateTable NVARCHAR(MAX)
DECLARE @ExecuteCreateSourceScript NVARCHAR(MAX)
DECLARE @ExecuteCreateConnectionScript NVARCHAR(MAX)


SELECT 
	 @ExecuteCreateTable = 'EXECUTE meta.[MaintainTargetCreateTableScript] @TargetObjectID = ''' + CAST(@TargetObjectID AS NVARCHAR(20)) + ''', @PrintSQL = 0'
	,@ExecuteCreateSourceScript = 'EXECUTE meta.[MaintainTargetCreateSourceScript] @TargetObjectID = ''' + CAST(@TargetObjectID AS NVARCHAR(20)) + ''', @PrintSQL = 0'
	,@ExecuteCreateConnectionScript = 'EXECUTE meta.[MaintainTargetCreateConnectionScript] @TargetObjectID = ''' + CAST(@TargetObjectID AS NVARCHAR(20)) + ''', @PrintSQL = 0'

EXEC(@ExecuteCreateTable)
EXEC(@ExecuteCreateSourceScript)
EXEC(@ExecuteCreateConnectionScript)

SET NOCOUNT OFF
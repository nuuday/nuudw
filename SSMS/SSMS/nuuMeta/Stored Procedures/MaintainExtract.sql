
CREATE PROCEDURE [nuuMeta].[MaintainExtract]
	@SourceObjectID INT ,
	@CreateTable BIT,
	@UpdateSourceScript BIT
AS

SET NOCOUNT ON

/**********************************************************************************************************************************************************************
1. Create Extract Tables
**********************************************************************************************************************************************************************/
DECLARE @ExecuteCreateTable NVARCHAR(MAX)
DECLARE @ExecuteCreateSourceScript NVARCHAR(MAX)

IF @CreateTable = 1
	EXECUTE nuuMeta.MaintainExtractCreateTable @SourceObjectID = @SourceObjectID

IF @UpdateSourceScript = 1
	EXECUTE nuuMeta.[MaintainExtractCreateSourceScript] @SourceObjectID = @SourceObjectID


SET NOCOUNT OFF
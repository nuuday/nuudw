
CREATE PROCEDURE [nuuMeta].[MaintainExtract]
	@SourceObjectID INT ,
	@CreateTable BIT,
	@UpdateSourceScript BIT
AS

SET NOCOUNT ON


/* Cleanup csv */
UPDATE nuuMeta.SourceObject
SET
	PrimaryKeyColumns = REPLACE(TRANSLATE(PrimaryKeyColumns,char(9)+char(13)+char(10),'   '),' ','') /* Remove blank, tab, line feed, carriage return */
	, HistoryTrackingColumns = REPLACE(TRANSLATE(HistoryTrackingColumns,char(9)+char(13)+char(10),'   '),' ','') /* Remove blank, tab, line feed, carriage return */
WHERE ID = @SourceObjectID


DECLARE @ExecuteCreateTable NVARCHAR(MAX)
DECLARE @ExecuteCreateSourceScript NVARCHAR(MAX)

IF @CreateTable = 1
	EXECUTE nuuMeta.MaintainExtractCreateTable @SourceObjectID = @SourceObjectID

IF @UpdateSourceScript = 1
	EXECUTE nuuMeta.[MaintainExtractCreateSourceScript] @SourceObjectID = @SourceObjectID


SET NOCOUNT OFF
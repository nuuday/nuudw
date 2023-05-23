
CREATE PROCEDURE [nuuMeta].[MaintainSourceObject]
	@SourceObjectID int
AS

UPDATE nuuMeta.SourceObject
SET
	PrimaryKeyColumns = REPLACE(TRANSLATE(PrimaryKeyColumns,char(9)+char(13)+char(10),'   '),' ','') /* Remove blank, tab, line feed, carriage return */
	, HistoryTrackingColumns = REPLACE(TRANSLATE(HistoryTrackingColumns,char(9)+char(13)+char(10),'   '),' ','') /* Remove blank, tab, line feed, carriage return */
	, SourceIsReadyQuery = COALESCE(SourceIsReadyQuery, 'SELECT 1 AS IsReady') /* Remove blank, tab, line feed, carriage return */
WHERE ID = @SourceObjectID
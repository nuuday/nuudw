

CREATE PROCEDURE [nuuMeta].[MaintainDW]

@DestinationSchema VARCHAR(10),
@DestinationTable VARCHAR(100),
@PrintSQL bit

AS

SET NOCOUNT ON


/* Cleanup csv */
UPDATE nuuMeta.DWObject
SET
	HistoryTrackingColumns = REPLACE(TRANSLATE(HistoryTrackingColumns,char(9)+char(13)+char(10)+'['+']','     '),' ','') /* Remove blank, tab, line feed, carriage return */
	, CubeSolutions = REPLACE(TRANSLATE(CubeSolutions,char(9)+char(13)+char(10)+'['+']','     '),' ','') /* Remove blank, tab, line feed, carriage return */


EXECUTE nuuMeta.[MaintainDWCreateTableAndView] @DestinationSchema = @DestinationSchema, @DestinationTable = @DestinationTable, @PrintSQL = @PrintSQL


SET NOCOUNT OFF


CREATE PROCEDURE [nuuMeta].[MaintainDW]

@DestinationSchema VARCHAR(10),
@DestinationTable VARCHAR(100)

AS

SET NOCOUNT ON


/* Cleanup csv */
UPDATE nuuMeta.DWObject
SET
	HistoryTrackingColumns = REPLACE(TRANSLATE(HistoryTrackingColumns,char(9)+char(13)+char(10),'   '),' ','') /* Remove blank, tab, line feed, carriage return */


EXECUTE nuuMeta.[MaintainDWCreateTableAndView] @DestinationSchema = @DestinationSchema, @DestinationTable = @DestinationTable, @PrintSQL = 0


SET NOCOUNT OFF
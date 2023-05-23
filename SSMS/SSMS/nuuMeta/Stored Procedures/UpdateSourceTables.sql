/**********************************************************************************************************************************************************************
The purpose of this scripts is to create the neccessary meta entries for incremental extract tables
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [nuuMeta].[UpdateSourceTables]

	@SourceConnectionType nvarchar(250),
	@SourceConnectionName nvarchar(250),
	@SourceSchemaName nvarchar(200),
	@SourceObjectName nvarchar(200),
	@DestinationSchemaName nvarchar(128),
	@WatermarkColumnName nvarchar(128),
	@WatermarkIsDate bit,
	@WatermarkRollingWindowDays int,
	@WatermarkInQuery nvarchar(500)

AS

SET NOCOUNT ON

UPDATE nuuMeta.SourceObject 
SET 
	[WatermarkColumnName] = @WatermarkColumnName, 
	[WatermarkIsDate] = @WatermarkIsDate, 
	[WatermarkRollingWindowDays] = @WatermarkRollingWindowDays, 
	[WatermarkInQuery] = @WatermarkInQuery
WHERE
	SourceConnectionName = @SourceConnectionName
	AND SourceSchemaName = @SourceSchemaName
	AND SourceObjectName = @SourceObjectName

DECLARE @Exists BIT = @@ROWCOUNT

IF @Exists = 0
BEGIN

	IF NOT EXISTS (SELECT * FROM nuuMeta.SourceConnection WHERE [SourceConnectionName] = @SourceConnectionName)
	BEGIN
		INSERT INTO nuuMeta.SourceConnection ([SourceConnectionType], [SourceConnectionName], [DestinationSchemaName])
		SELECT @SourceConnectionType, @SourceConnectionName, @DestinationSchemaName
	END 

	INSERT INTO nuuMeta.SourceObject ([SourceConnectionName], [SourceSchemaName], [SourceObjectName], [ExtractPattern], [HistoryType], [WatermarkColumnName], [WatermarkIsDate], [WatermarkRollingWindowDays], [WatermarkInQuery])
	SELECT @SourceConnectionName, @SourceSchemaName, @SourceObjectName, 'Dummy', 'None', @WatermarkColumnName, @WatermarkIsDate, @WatermarkRollingWindowDays, @WatermarkInQuery

END

SET NOCOUNT OFF




CREATE PROCEDURE [nuuMeta].[GetLastValueLoaded] 

	@SourceConnectionName nvarchar(200)
	, @SourceCatalogName nvarchar(200)
	, @SourceSchemaName nvarchar(200)
	, @SourceTableName nvarchar(200)
	, @JobIsIncremental BIT
	, @ConnectionType NVARCHAR(50)
	, @WatermarkIsDate BIT

AS

/*
DECLARE 
	@SourceConnectionName nvarchar(200) = 'nuudata'
	, @SourceCatalogName nvarchar(200) = 'dai'
	, @SourceSchemaName nvarchar(200) = 'sourceDataLakeChipper'
	, @SourceTableName nvarchar(200) = 'TicketsEventLog_History'
	, @JobIsIncremental BIT = 1
	, @ConnectionType NVARCHAR(50)  = 'SqlServer'
	, @WatermarkIsDate BIT = 1
--*/

SET NOCOUNT ON

SELECT
	CASE
		WHEN @JobIsIncremental = 0 AND @WatermarkIsDate = 1 AND @ConnectionType NOT IN ('Oracle', 'MSORA') THEN '19000101000000'
		WHEN @JobIsIncremental = 0 AND @WatermarkIsDate = 1 AND @ConnectionType IN ('Oracle', 'MSORA') THEN '01010101000000'
		WHEN @JobIsIncremental = 0 AND @WatermarkIsDate = 1 AND @ConnectionType IN ('AzureDatabricksDeltaLake') THEN '1900-01-01 00:00:00'
		WHEN @JobIsIncremental = 0 AND @ConnectionType IN ('AzureBlobFS') THEN '1900-01-01T00:00:00.0000000Z'
		WHEN @JobIsIncremental = 0 AND @WatermarkIsDate = 0 THEN '0'
		WHEN @JobIsIncremental = 1 AND @WatermarkIsDate = 1 AND @ConnectionType IN ('AzureDatabricksDeltaLake') THEN so.WatermarkLastValue
		WHEN @JobIsIncremental = 1 AND @WatermarkIsDate = 1 THEN FORMAT( CONVERT( DATETIME, STUFF( STUFF( STUFF( STUFF( STUFF( ISNULL(NULLIF(so.WatermarkLastValue,N'0'),'19000101000000'), 13, 0, ':' ), 11, 0, ':' ), 9, 0, ' ' ), 7, 0, '-'), 5, 0, '-') ), 'yyyyMMddHHmmss' )
		ELSE so.WatermarkLastValue
	END AS LastValueLoaded
FROM nuuMeta.SourceObject so
WHERE
	so.SourceConnectionName = @SourceConnectionName
	AND so.SourceCatalogName = @SourceCatalogName
	AND so.SourceSchemaName = @SourceSchemaName
	AND so.SourceObjectName = @SourceTableName

SET NOCOUNT OFF
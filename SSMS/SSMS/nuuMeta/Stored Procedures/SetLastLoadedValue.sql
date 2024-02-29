

/**********************************************************************************************************************************************************************
The purpose of this scripts is set LastValueLoaded in the table SourceObjectWatermarkSetup
***********************************************************************************************************************************************************************/

CREATE PROCEDURE [nuuMeta].[SetLastLoadedValue] 

	@SourceConnectionName nvarchar(200)
	, @SourceSchemaName nvarchar(200)
	, @SourceTableName nvarchar(200)
	, @WatermarkIsDate BIT
	, @PrintSQL BIT = 0

AS

SET NOCOUNT ON

/*
DECLARE   
	@SourceConnectionName NVARCHAR(100) = 'nuudata'
	, @SourceSchemaName NVARCHAR(100) = 'sourceDataLakeChipper'
	, @SourceTableName NVARCHAR(100) = 'TicketsEventLog_History'
	, @WatermarkIsDate BIT = 1
	, @PrintSQL BIT= 1
--*/

/**********************************************************************************************************************************************************************
Support variables
***********************************************************************************************************************************************************************/

DECLARE @WatermarkValueColumn NVARCHAR(500)
DECLARE @ExtractSchemaName NVARCHAR(500)
DECLARE @SourceObjectID NVARCHAR(500)
DECLARE @LastValueLoaded NVARCHAR(500)


SELECT 
	@WatermarkValueColumn = IIF(so.WatermarkInQuery <> '',so.WatermarkInQuery, CASE WHEN LEFT(so.WatermarkColumnName,2) = 'DW' THEN '[SRC_' +  so.WatermarkColumnName + ']' ELSE so.WatermarkColumnName END),
	@LastValueLoaded = so.WatermarkLastValue,
	@ExtractSchemaName = co.DestinationSchemaName,
	@SourceObjectID = CAST(so.ID as nvarchar)
FROM nuuMeta.SourceObject so
INNER JOIN nuuMeta.SourceConnection co ON co.SourceConnectionName = so.SourceConnectionName
WHERE
	so.SourceConnectionName = @SourceConnectionName
	AND so.SourceSchemaName = @SourceSchemaName
	AND so.SourceObjectName = @SourceTableName


/**********************************************************************************************************************************************************************
1. Execute dynamic SQL script variables
***********************************************************************************************************************************************************************/

DECLARE @SQL NVARCHAR(MAX) 
DECLARE @SQLMaxLvl NVARCHAR(max);  
DECLARE @ParmDefinition NVARCHAR(500);  
DECLARE @max_lastvalueloaded VARCHAR(50);  
DECLARE @LastValueLoadedParam bigint = 0;
  
SET @max_lastvalueloaded = @LastValueLoaded;  
SET @ParmDefinition = N'@level TINYINT, @max_lastvalueloadedOUT VARCHAR(30) OUTPUT';  

SET @SQLMaxLvl = 'SELECT @max_lastvalueloadedOUT = ISNULL((SELECT CONVERT(NVARCHAR, ' + iif (@WatermarkIsDate = 1,'FORMAT(MAX(' + @WatermarkValueColumn + '), ''yyyy-MM-dd HH:mm:ss.ffffff''))', 
	'MAX(' + @WatermarkValueColumn + '))') + ' FROM [' + @ExtractSchemaName + '].[' + @SourceTableName + ']), '''+@LastValueLoaded+''')'

PRINT @SQLMaxLvl
EXECUTE sp_executesql @SQLMaxLvl, @ParmDefinition, @level = 197, @max_lastvalueloadedOUT=@max_lastvalueloaded OUTPUT;  


SET @SQL = '
UPDATE nuuMeta.SourceObject 
SET [WatermarkLastValue] = '''+CAST(@max_lastvalueloaded AS nvarchar(50))+'''
WHERE ID = ' + @SourceObjectID


IF @PrintSQL = 1
BEGIN
	PRINT(@SQL)
END
ELSE
BEGIN
		EXEC(@SQL)
END

SET NOCOUNT OFF
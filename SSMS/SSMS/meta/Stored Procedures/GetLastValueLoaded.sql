

CREATE PROCEDURE [meta].[GetLastValueLoaded] 

  @TableName NVARCHAR(100)
, @ExtractSchemaName NVARCHAR(100)
, @JobIsIncremental BIT
, @ConnectionType NVARCHAR(50)

AS

SET NOCOUNT ON

SELECT 
	  IIF(ISNULL(SourceObjectIncrementalSetup.IncrementalValueColumnDefinitionInExtract,'') = '', SourceObjectIncrementalSetup.IncrementalValueColumnDefinition,SourceObjectIncrementalSetup.IncrementalValueColumnDefinitionInExtract) AS IncrementalValueColumnDefinition
	, CASE
			WHEN @JobIsIncremental = 0 AND IsDateFlag = 1 AND @ConnectionType NOT IN ('Oracle','MSORA') THEN '19000101000000'
			WHEN @JobIsIncremental = 0 AND IsDateFlag = 1 AND @ConnectionType IN ('Oracle','MSORA') THEN '01010101000000'
			WHEN @JobIsIncremental = 0 AND IsDateFlag = 0 THEN '0'
			WHEN @JobIsIncremental = 1 AND IsDateFlag = 1 THEN FORMAT(DATEADD(DD,RollingWindowDays,CONVERT(datetime,STUFF(STUFF(STUFF(SourceObjectIncrementalSetup.LastValueLoaded,13,0,':'),11,0,':'),9,0,' '))),'yyyyMMddHHmmss')
			ELSE SourceObjectIncrementalSetup.LastValueLoaded
	  END AS LastValueLoaded
FROM 
	meta.SourceObjectIncrementalSetup 
INNER JOIN 
	meta.SourceObjects
		ON SourceObjectIncrementalSetup.SourceObjectID = SourceObjects.ID
INNER JOIN
	(SELECT ID, ExtractSchemaName, ROW_NUMBER() OVER (PARTITION BY ExtractSchemaName ORDER BY ID) AS RowN FROM meta.SourceConnections) AS SourceConnections
		ON SourceConnections.ID = SourceObjects.SourceConnectionID
		AND RowN = 1
WHERE 
	SourceObjects.ObjectName = @TableName
	AND SourceConnections.ExtractSchemaName = @ExtractSchemaName

SET NOCOUNT OFF
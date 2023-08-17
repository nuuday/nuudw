CREATE PROCEDURE [nuuMeta].[GetSourceSchemaName] 

	@SourceConnectionName nvarchar(200)
	, @SourceSchemaName nvarchar(200)
	, @SourceTableName nvarchar(200)

AS

/*
DECLARE 
	@SourceConnectionName nvarchar(200) = 'nuudl_netcracker'
	, @SourceSchemaName nvarchar(200) = 'netcracker'
	, @SourceTableName nvarchar(200) = 'customer'
--*/

SET NOCOUNT ON

SELECT COALESCE(ds.SourceSchemaName, so.SourceSchemaName) AS SourceSchemaName
FROM nuuMeta.SourceObject so
INNER JOIN nuuMeta.SourceConnection sc ON sc.SourceConnectionName = so.SourceConnectionName
LEFT JOIN nuuMeta.SourceObjectDynamicSchema ds ON ds.SourceObjectID = so.ID AND ds.Environment = sc.Environment
WHERE
	so.SourceConnectionName = @SourceConnectionName
	AND so.SourceSchemaName = @SourceSchemaName
	AND so.SourceObjectName = @SourceTableName

SET NOCOUNT OFF
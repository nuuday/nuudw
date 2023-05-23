

CREATE VIEW [nuuMetaView].[ExtractControllerDefinitions]
AS
SELECT 
	'0.1_Extracts' AS ADFFolder,
	'EXT_0_' + SourceConnectionName AS ADFControllerName,
	ADFPipelineName,
	SourceObjectName AS ADFPipelineActivityName,
	SourceConnectionName,
	SourceConnectionID
FROM nuuMetaView.SourceObjectDefinitions
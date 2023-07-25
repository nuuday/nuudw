


CREATE VIEW [nuuMetaView].[ExtractControllerDefinitions]
AS
WITH gross_list AS (
	SELECT 
		'0.1_Extracts' AS ADFFolder,
		'EXT_0_' + SourceConnectionName AS ADFControllerName,
		ADFPipelineName,
		SourceObjectName AS ADFPipelineActivityName,
		SourceConnectionName,
		SourceConnectionID,
		FLOOR((ROW_NUMBER() OVER (PARTITION BY SourceConnectionName ORDER BY ADFPipelineName) - 1) / 40) + 1  AS SubGroupNumber /* A pipeline can maximum contain 40 activites */
	FROM nuuMetaView.SourceObjectDefinitions
)

SELECT 
	ADFFolder,
	CASE
		WHEN SubGroupNumber > 1 THEN ADFControllerName + '_' + CAST(SubGroupNumber AS VARCHAR)
		ELSE ADFControllerName
	END ADFControllerName,
	ADFPipelineName,
	ADFPipelineActivityName,
	SourceConnectionName,
	SourceConnectionID
FROM gross_list





CREATE VIEW [meta].[TabularStudioDefinition] AS
SELECT DISTINCT meta.SplitCamelCase(dwr.[TableName]) AS FactOrBridgeName
      ,meta.SplitCamelCase(dwr.[DimensionName]) AS DimensionName
      ,meta.SplitCamelCase(dwr.[RolePlayingDimensionName]) AS RolePlayingDimensionName
	  ,dwr.[RolePlayingDimensionName] + 'ID' AS FactOrBridgeIDColumn
	  ,dwr.DimensionName + 'ID' AS DimensionIDColumn
      ,bm.DestinationSchema + 'View' as FactOrBridgeSchema
  FROM 
	meta.[DWRelations] dwr LEFT JOIN
	meta.BusinessMatrix bm ON dwr.TableName = bm.TableName
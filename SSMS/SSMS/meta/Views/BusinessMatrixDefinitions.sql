
 

 
 CREATE VIEW [meta].[BusinessMatrixDefinitions]

 AS
 
 

	SELECT
		 BusinessMatrix.ID
		,DestinationSchema
		,TableName
		,IIF((SELECT VariableValue FROM meta.Variables WHERE VariableName = 'FactLoadEngine') = 'SQL' AND DestinationSchema IN ('fact','bridge'),'SQL',LoadPattern) AS LoadPattern
		,IIF((SELECT VariableValue FROM meta.Variables WHERE VariableName = 'IsCloudFlag') = '1','SQL',LoadPattern) AS TransformPattern
		,LoadPattern AS ExecutionPattern
		,FactAndBridgeIncrementalFlag
		,SCD2DimensionFlag
		,PackageDependencyFlag
		,TransformExcludeFlag
		,DWExcludeFlag
		,ControllerExcludeFlag
		,UPPER(LEFT(BusinessMatrix.[DestinationSchema],1)) + SUBSTRING(BusinessMatrix.[DestinationSchema],2,LEN(BusinessMatrix.[DestinationSchema])-1) AS CapitalisedDestinationSchema
		,FrameworkMetaData.SQLScript
		,(SELECT VariableValue FROM meta.Variables WHERE VariableName = 'FactInMemoryFlag') AS FactInMemoryFlag
		,(SELECT VariableValue FROM meta.Variables WHERE VariableName = 'FactLoadEngine') AS LoadEngine
	    ,(SELECT VariableValue FROM meta.Variables WHERE VariableName = 'IsCloudFlag') AS IsCloudFlag
		,(SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameMeta') AS DatabaseName
	FROM
		meta.BusinessMatrix
	LEFT JOIN
		meta.FrameworkMetaData
			ON FrameworkMetaData.BusinessMatrixID = BusinessMatrix.ID
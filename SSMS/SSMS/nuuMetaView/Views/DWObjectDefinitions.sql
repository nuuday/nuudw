







CREATE VIEW [nuuMetaView].[DWObjectDefinitions]
AS
SELECT 
	ID AS DWObjectID,
	[DWObjectType],
	[DWObjectName],
	[LoadPattern],
	CASE 
		WHEN LoadProcedure = '' AND DWObjectType = 'Link' THEN ''
		WHEN LoadProcedure = '' AND DWObjectType = 'Dimension' THEN '[nuuMeta].[LoadDimension]'
		WHEN LoadProcedure = '' AND DWObjectType = 'Fact' THEN '[nuuMeta].[LoadFact]'
		WHEN LoadProcedure = '' AND DWObjectType = 'Bridge' THEN '[nuuMeta].[LoadFact]'
		ELSE LoadProcedure
	END AS LoadProcedure,
	CASE 
		WHEN DWObjectType = 'Link' THEN 'link.Transform_' + DWObjectName
		WHEN DWObjectType = 'Dimension' THEN 'stage.Transform_Dim_' + DWObjectName
		WHEN DWObjectType = 'Fact' THEN 'stage.Transform_Fact_' + DWObjectName
		WHEN DWObjectType = 'Bridge' THEN 'stage.Transform_Bridge_' + DWObjectName
		ELSE ''
	END AS TransformProcedureName,
	'stage' AS StageSchemaName,
	CASE 
		WHEN DWObjectType = 'Link' THEN DWObjectName
		WHEN DWObjectType = 'Dimension' THEN 'Dim_' + DWObjectName
		WHEN DWObjectType = 'Fact' THEN 'Fact_' + DWObjectName
		WHEN DWObjectType = 'Bridge' THEN 'Bridge_' + DWObjectName
		ELSE ''
	END AS StageTableName,
	CASE 
		WHEN DWObjectType = 'Dimension' THEN 'dim'
		WHEN DWObjectType = 'Fact' THEN 'fact'
		WHEN DWObjectType = 'Bridge' THEN 'bridge'
		ELSE ''
	END AS DWSchemaName,
	CASE 
		WHEN DWObjectType = 'Dimension' THEN DWObjectName
		WHEN DWObjectType = 'Fact' THEN DWObjectName
		WHEN DWObjectType = 'Bridge' THEN DWObjectName
		ELSE ''
	END AS DWTableName,
	CASE 
		WHEN DWObjectType = 'Link' THEN '0.2_Links'
		WHEN DWObjectType = 'Dimension' THEN '0.3_Dimensions'
		WHEN DWObjectType = 'Fact' THEN '0.4_Facts'
		WHEN DWObjectType = 'Bridge' THEN '0.5_Bridge'
		ELSE ''
	END AS PipelineFolder,
		CASE 
		WHEN DWObjectType = 'Link' THEN 'LINK_1_'+[DWObjectName]+'_Transform'
		WHEN DWObjectType = 'Dimension' THEN 'DIM_1_'+[DWObjectName]+'_Transform'
		WHEN DWObjectType = 'Fact' THEN 'FACT_1_'+[DWObjectName]+'_Transform'
		WHEN DWObjectType = 'Bridge' THEN 'BRIDGE_1_'+[DWObjectName]+'_Transform'
		ELSE ''
	END AS TransformPipelineName,
	CASE 
		WHEN DWObjectType = 'Link' THEN ''
		WHEN DWObjectType = 'Dimension' THEN 'DIM_1_'+[DWObjectName]+'_Load'
		WHEN DWObjectType = 'Fact' THEN 'FACT_1_'+[DWObjectName]+'_Load'
		WHEN DWObjectType = 'Bridge' THEN 'BRIDGE_1_'+[DWObjectName]+'_Load'
		ELSE ''
	END AS LoadPipelineName,
	CASE 
		WHEN DWObjectType = 'Link' THEN 'LINK_0_'+[DWObjectName]
		WHEN DWObjectType = 'Dimension' THEN 'DIM_0_'+[DWObjectName]
		WHEN DWObjectType = 'Fact' THEN 'FACT_0_'+[DWObjectName]
		WHEN DWObjectType = 'Bridge' THEN 'BRIDGE_0_'+[DWObjectName]
		ELSE ''
	END AS ControllerPipelineName ,
	CASE 
		WHEN DWObjectType = 'Link' THEN 'MaintainDW_Link_'+[DWObjectName]
		WHEN DWObjectType = 'Dimension' THEN 'MaintainDW_Dim_'+[DWObjectName]
		WHEN DWObjectType = 'Fact' THEN 'MaintainDW_Fact_'+[DWObjectName]
		WHEN DWObjectType = 'Bridge' THEN 'MaintainDW_Bridge_'+[DWObjectName]
		ELSE ''
	END AS MaintainDWPipelineName 		
FROM [nuuMeta].[DWObject]
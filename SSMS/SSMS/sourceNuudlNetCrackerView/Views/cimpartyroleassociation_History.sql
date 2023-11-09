
CREATE VIEW [sourceNuudlNetCrackerView].[cimpartyroleassociation_History]
AS
SELECT 
	[id] ,
	[ref_type_from] ,
	[id_from] ,
	[ref_type_to] ,
	[id_to] ,
	[association_role] ,
	[association_name] ,
	[active_from] ,
	[changed_by_json_userId] ,
	[changed_by_json_userName] ,
	[is_deleted] ,
	[last_modified_ts] ,
	[active_to] ,
	[version] ,
	[is_current] ,
	[NUUDL_ValidFrom] ,
	[NUUDL_ValidTo] ,
	[NUUDL_IsCurrent] ,
	[NUUDL_ID] ,
	[NUUDL_CuratedBatchID] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuudlNetCracker].[cimpartyroleassociation_History]
WHERE DWIsCurrent = 1
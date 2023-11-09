
CREATE VIEW [sourceNuudlNetCrackerView].[cimcontactmediumassociation_History]
AS
SELECT 
	[id] ,
	[ref_id] ,
	[ref_type] ,
	[contact_medium_id] ,
	[changed_by_json_userId] ,
	[active_from] ,
	[is_deleted] ,
	[last_modified_ts] ,
	[active_to] ,
	[version] ,
	[is_current] ,
	[changed_by_json_userName] ,
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
FROM [sourceNuudlNetCracker].[cimcontactmediumassociation_History]
WHERE DWIsCurrent = 1
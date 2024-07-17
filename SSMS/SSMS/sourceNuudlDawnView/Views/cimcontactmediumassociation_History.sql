
CREATE VIEW [sourceNuudlDawnView].[cimcontactmediumassociation_History]
AS
SELECT 
	[active_from] ,
	[changed_by] ,
	[contact_medium_id] ,
	[id] ,
	[op] ,
	[ref_id] ,
	[ref_type] ,
	[ts_ms] ,
	[NUUDL_CuratedBatchID] ,
	[NUUDL_CuratedProcessedTimestamp] ,
	[NUUDL_IsCurrent] ,
	[NUUDL_ValidFrom] ,
	[NUUDL_ValidTo] ,
	[NUUDL_ID] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuudlDawn].[cimcontactmediumassociation_History]
WHERE DWIsCurrent = 1
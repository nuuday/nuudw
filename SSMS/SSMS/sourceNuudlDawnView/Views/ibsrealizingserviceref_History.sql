
CREATE VIEW [sourceNuudlDawnView].[ibsrealizingserviceref_History]
AS
SELECT 
	[id] ,
	[name] ,
	[product_instance_id] ,
	[ref_id] ,
	[ref_type] ,
	[role] ,
	[ts_ms] ,
	[lsn] ,
	[op] ,
	[NUUDL_IsCurrent] ,
	[NUUDL_ValidFrom] ,
	[NUUDL_ValidTo] ,
	[NUUDL_CuratedBatchID] ,
	[NUUDL_CuratedProcessedTimestamp] ,
	[NUUDL_IsDeleted] ,
	[NUUDL_DeleteType] ,
	[NUUDL_IsLatest] ,
	[NUUDL_ID] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuudlDawn].[ibsrealizingserviceref_History]
WHERE DWIsCurrent = 1
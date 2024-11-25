
CREATE VIEW [sourceNuudlDawnView].[ibsnrmlrelatedpartyref_History]
AS
SELECT 
	[_corrupt_record] ,
	[name] ,
	[product_instance_id] ,
	[related_party_ref_id] ,
	[related_party_ref_type] ,
	[role] ,
	[user_of_service] ,
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
	[NUUDL_ID] ,
	[NUUDL_IsLatest] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuudlDawn].[ibsnrmlrelatedpartyref_History]
WHERE DWIsCurrent = 1
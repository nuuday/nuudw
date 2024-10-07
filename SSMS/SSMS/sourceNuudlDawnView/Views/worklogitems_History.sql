

CREATE VIEW [sourceNuudlDawnView].[worklogitems_History]
AS
SELECT 
	[attributes] ,
	[changedby] ,
	[date] ,
	[description] ,
	[id] ,
	[name] ,
	[ref_id] ,
	[ref_type] ,
	[source] ,
	[source_state] ,
	[target_state] ,
	[ts_ms] ,
	[lsn] ,
	[op] ,
	[changedby_userId] ,
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
FROM [sourceNuudlDawn].[worklogitems_History]
WHERE DWIsCurrent = 1
and ISNULL(NUUDL_DeleteType,'') <> 'technical_delete'
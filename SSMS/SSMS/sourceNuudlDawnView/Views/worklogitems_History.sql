
CREATE VIEW[sourceNuudlDawnView].[worklogitems_History]
AS
SELECT 
	[attributes] ,
	[changedby] ,
	[date] ,
	[description] ,
	[id] ,
	[name] ,
	[op] ,
	[ref_id] ,
	[ref_type] ,
	[source] ,
	[source_state] ,
	[target_state] ,
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
	,[NUUDL_IsDeleted]
	,[NUUDL_DeleteType]
	,[NUUDL_IsLatest]
	,lsn
FROM [sourceNuudlDawn].[worklogitems_History]
WHERE DWIsCurrent = 1
and ISNULL(NUUDL_DeleteType,'') not like '%technical_delete%'
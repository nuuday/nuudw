
CREATE VIEW [sourceNuudlDawnView].[ibsitemshistory_History]
AS
SELECT 
	[active_from] ,
	[active_to] ,
	[id] ,
	[idempotency_key] ,
	[is_snapshot] ,
	[item] ,
	[last_modified_ts] ,
	[op] ,
	[schema_version] ,
	[state] ,
	[ts_ms] ,
	[version] ,
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
FROM [sourceNuudlDawn].[ibsitemshistory_History]
WHERE DWIsCurrent = 1
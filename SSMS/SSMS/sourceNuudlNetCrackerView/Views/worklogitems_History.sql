
CREATE VIEW [sourceNuudlNetCrackerView].[worklogitems_History]
AS
SELECT 
	[id] ,
	[name] ,
	[description] ,
	[date] ,
	[source] ,
	[ref_id] ,
	[ref_type] ,
	[source_state] ,
	[target_state] ,
	[attributes] ,
	[is_deleted] ,
	[last_modified_ts] ,
	[is_current] ,
	[changedby_json_m2m] ,
	[changedby_json_service] ,
	[changedby_json_userId] ,
	[changedby_json_userName] ,
	[NUUDL_ValidFrom] ,
	[NUUDL_ValidTo] ,
	[NUUDL_IsCurrent] ,
	[NUUDL_ID] ,
	[NUUDL_StandardizedProcessedTimestamp] ,
	[NUUDL_CuratedBatchID] ,
	[NUUDL_CuratedProcessedTimestamp] ,
	[NUUDL_CuratedSourceFilename] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuudlNetCracker].[worklogitems_History]
WHERE DWIsCurrent = 1
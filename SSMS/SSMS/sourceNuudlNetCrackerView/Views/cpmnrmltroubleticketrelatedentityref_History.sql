
CREATE VIEW [sourceNuudlNetCrackerView].[cpmnrmltroubleticketrelatedentityref_History]
AS
SELECT 
	[id] ,
	[type] ,
	[name] ,
	[role] ,
	[trouble_ticket_id] ,
	[is_deleted] ,
	[last_modified_ts] ,
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
FROM [sourceNuudlNetCracker].[cpmnrmltroubleticketrelatedentityref_History]
WHERE DWIsCurrent = 1
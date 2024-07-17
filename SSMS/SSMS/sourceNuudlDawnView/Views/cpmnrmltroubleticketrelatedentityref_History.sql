
CREATE VIEW [sourceNuudlDawnView].[cpmnrmltroubleticketrelatedentityref_History]
AS
SELECT 
	[id] ,
	[name] ,
	[op] ,
	[role] ,
	[trouble_ticket_id] ,
	[ts_ms] ,
	[type] ,
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
FROM [sourceNuudlDawn].[cpmnrmltroubleticketrelatedentityref_History]
WHERE DWIsCurrent = 1
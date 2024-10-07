
CREATE VIEW [sourceNuudlDawnView].[nrmaccountkeyname_History]
AS
SELECT 
	[account_num] ,
	[name] ,
	[op] ,
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
FROM [sourceNuudlDawn].[nrmaccountkeyname_History]
WHERE DWIsCurrent = 1
and ISNULL(NUUDL_DeleteType,'') <> 'technical_delete'
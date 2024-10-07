
CREATE VIEW [sourceNuudlDawnView].[orgchrteammember_History]
AS
SELECT 
	[contact_medium] ,
	[distribution_channel] ,
	[end_date] ,
	[extended_parameters] ,
	[external_id] ,
	[first_name] ,
	[geographic_site] ,
	[id] ,
	[idm_roles] ,
	[idm_user_id] ,
	[last_name] ,
	[name] ,
	[op] ,
	[position] ,
	[skill] ,
	[start_date] ,
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
FROM [sourceNuudlDawn].[orgchrteammember_History]
WHERE DWIsCurrent = 1
and ISNULL(NUUDL_DeleteType,'') <> 'technical_delete'
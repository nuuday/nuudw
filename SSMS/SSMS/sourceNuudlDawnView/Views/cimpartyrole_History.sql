
CREATE VIEW [sourceNuudlDawnView].[cimpartyrole_History]
AS
SELECT 
	[active_from] ,
	[billing_synchronization_status] ,
	[changed_by] ,
	[end_date_time] ,
	[engaged_party_description] ,
	[engaged_party_id] ,
	[engaged_party_name] ,
	[engaged_party_ref_type] ,
	[extended_attributes] ,
	[id] ,
	[idempotency_key] ,
	[name] ,
	[ola_ref] ,
	[op] ,
	[party_role_type] ,
	[start_date_time] ,
	[status] ,
	[status_reason] ,
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
FROM [sourceNuudlDawn].[cimpartyrole_History]
WHERE DWIsCurrent = 1
and NUUDL_DeleteType not like '%technical_delete%'

CREATE VIEW [sourceNuudlNetCrackerView].[cimpartyrole_History]
AS
SELECT 
	[id] ,
	[active_from] ,
	[name] ,
	[party_role_type] ,
	[status] ,
	[status_reason] ,
	[engaged_party_name] ,
	[engaged_party_description] ,
	[engaged_party_id] ,
	[engaged_party_ref_type] ,
	[extended_attributes] ,
	[changed_by_json_userId] ,
	[start_date_time] ,
	[end_date_time] ,
	[billing_synchronization_status] ,
	[idempotency_key] ,
	[ola_ref] ,
	[is_deleted] ,
	[last_modified_ts] ,
	[active_to] ,
	[version] ,
	[is_current] ,
	[changed_by_json_userName] ,
	[NUUDL_ValidFrom] ,
	[NUUDL_ValidTo] ,
	[NUUDL_IsCurrent] ,
	[NUUDL_ID] ,
	[NUUDL_CuratedBatchID] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuudlNetCracker].[cimpartyrole_History]
WHERE DWIsCurrent = 1
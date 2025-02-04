
CREATE VIEW [sourceNuudlDawnView].[esonrmlserviceinstances_History]
AS
SELECT 
	[_corrupt_record] ,
	[activated_when] ,
	[complex_service_data] ,
	[created_date] ,
	[customer_account_id] ,
	[description] ,
	[domain] ,
	[id] ,
	[is_test_service] ,
	[last_modified_date] ,
	[service_model_name] ,
	[service_model_service_specification_id] ,
	[service_model_service_specification_name] ,
	[service_model_service_specification_version] ,
	[service_model_state] ,
	[service_type] ,
	[ts_ms] ,
	[lsn] ,
	[op] ,
	[NUUDL_IsCurrent] ,
	[NUUDL_ValidFrom] ,
	[NUUDL_ValidTo] ,
	[NUUDL_CuratedBatchID] ,
	[NUUDL_CuratedProcessedTimestamp] ,
	[NUUDL_IsDeleted] ,
	[NUUDL_DeleteType] ,
	[NUUDL_IsLatest] ,
	[NUUDL_ID] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuudlDawn].[esonrmlserviceinstances_History]
WHERE DWIsCurrent = 1
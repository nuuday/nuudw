
CREATE VIEW [sourceNuudlDawnView].[qssnrmlquote_History]
AS
SELECT 
	[approval_level] ,
	[assign_to] ,
	[brand_id] ,
	[business_action] ,
	[cancellation_reason] ,
	[customer_category_id] ,
	[customer_committed_date] ,
	[customer_id] ,
	[customer_requested_date] ,
	[delivery_method] ,
	[distribution_channel_id] ,
	[expiration_date] ,
	[extended_parameters] ,
	[external_id] ,
	[id] ,
	[initial_distribution_channel_id] ,
	[name] ,
	[new_msa] ,
	[number] ,
	[op] ,
	[opportunity_id] ,
	[override_mode] ,
	[owner] ,
	[price_list_id] ,
	[quote_creation_date] ,
	[revision] ,
	[state] ,
	[state_change_reason] ,
	[ts_ms] ,
	[updated_when] ,
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
	,[NUUDL_IsDeleted]
	,[NUUDL_DeleteType]
	,[NUUDL_IsLatest]
FROM [sourceNuudlDawn].[qssnrmlquote_History]
WHERE DWIsCurrent = 1
and ISNULL(NUUDL_DeleteType,'') <> 'technical_delete'

CREATE VIEW [sourceNuudlDawnView].[phonenumbers_History]
AS
SELECT 
	[aging_period_end_date] ,
	[area_code] ,
	[category] ,
	[country_code] ,
	[customer_account_id] ,
	[description] ,
	[extended_parameters] ,
	[first_owner_id] ,
	[national_prefix] ,
	[op] ,
	[perform_auto_categorization] ,
	[phone_number] ,
	[ported_in] ,
	[ported_in_from] ,
	[ported_out] ,
	[ported_out_to] ,
	[serving_switch_id] ,
	[status] ,
	[status_change_date] ,
	[subrange_id] ,
	[top_range_id] ,
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
FROM [sourceNuudlDawn].[phonenumbers_History]
WHERE DWIsCurrent = 1
and NUUDL_DeleteType not like '%technical_delete%'
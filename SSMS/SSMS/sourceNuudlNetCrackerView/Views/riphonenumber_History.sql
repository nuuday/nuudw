
CREATE VIEW [sourceNuudlNetCrackerView].[riphonenumber_History]
AS
SELECT 
	[phone_number] ,
	[description] ,
	[status] ,
	[category] ,
	[perform_auto_categorization] ,
	[serving_switch_id] ,
	[top_range_id] ,
	[subrange_id] ,
	[customer_account_id] ,
	[ported_in] ,
	[ported_out] ,
	[extended_parameters_json__corrupt_record] ,
	[aging_period_end_date] ,
	[status_change_date] ,
	[first_owner_id] ,
	[ported_in_from] ,
	[ported_out_to] ,
	[country_code] ,
	[area_code] ,
	[national_prefix] ,
	[is_deleted] ,
	[last_modified_ts] ,
	[is_current] ,
	[extended_parameters_json_brand_id] ,
	[extended_parameters_json_sp_id] ,
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
FROM [sourceNuudlNetCracker].[riphonenumber_History]
WHERE DWIsCurrent = 1
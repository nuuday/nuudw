

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
	CASE 
		WHEN [ported_in] LIKE '%false%' OR [ported_in] = '0' THEN '0' 
		WHEN [ported_in] LIKE '%true%' OR [ported_in] = '1' THEN '1'	
	END [ported_in],
	[ported_in_from] ,
	CASE 
		WHEN [ported_out] LIKE '%false%' OR [ported_out] = '0' THEN '0' 
		WHEN [ported_out] LIKE '%true%' OR [ported_out] = '1' THEN '1'	
	END [ported_out],
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
	,lsn
FROM [sourceNuudlDawn].[phonenumbers_History]
WHERE DWIsCurrent = 1
and ISNULL(NUUDL_DeleteType,'') <> 'technical_delete'
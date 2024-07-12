

CREATE VIEW [sourceNuudlNetCrackerView].[ibsnrmlproductinstance_History]
AS
SELECT 
	[account_ref_id] ,
	[business_group] ,
	[contracted_date] ,
	[customer_id] ,
	[description] ,
	[disconnection_reason] ,
	[disconnection_reason_description] ,
	[effective_date] ,
	CAST([effective_date] AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' as datetime) [effective_date_CET],
	[eligibility_param_id] ,
	[extended_attributes_json__corrupt_record] ,
	[extended_eligibility] ,
	[external_id] ,
	[id] ,
	[idempotency_key] ,
	[last_modified] ,
	[expiration_date] ,
	[name] ,
	[number_of_installments] ,
	[offering_id] ,
	[override_mode] ,
	[parent_id] ,
	[place_ref_id] ,
	[product_order_id] ,
	[product_specification_id] ,
	[product_specification_version] ,
	[quantity] ,
	[quote_id] ,
	[root_id] ,
	[source_quote_item_id] ,
	[start_date] ,
	[state] ,
	[suspended] ,
	[termination_date] ,
	[type] ,
	[version] ,
	[is_deleted] ,
	[last_modified_ts] ,
	[is_current] ,
	[extended_attributes_json_key] ,
	[extended_attributes_json_value] ,
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
FROM [sourceNuudlNetCracker].[ibsnrmlproductinstance_History]
WHERE DWIsCurrent = 1
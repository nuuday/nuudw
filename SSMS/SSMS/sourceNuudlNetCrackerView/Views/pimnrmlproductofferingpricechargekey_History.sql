

CREATE VIEW [sourceNuudlNetCrackerView].[pimnrmlproductofferingpricechargekey_History]
AS
SELECT 
	[available_from] ,
	[available_to] ,
	CAST([available_from] AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' as datetime) [available_from_CET],
	CAST([available_to] AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' as datetime) [available_to_CET],
	[currency_id] ,
	[localized_name] ,
	[id] ,
	[is_base] ,
	[is_default] ,
	[name] ,
	[price_list_id] ,
	[prod_offering_price_spec_id] ,
	[alternate_price_key_id] ,
	[external_id] ,
	[prod_offering_id] ,
	[tangible_product_sale_type_id] ,
	[installment_plan_id] ,
	[price_eligibility_condition_id] ,
	[cdc_revision_id] ,
	[prod_offering_price_policy_condition_ids_json__corrupt_record] ,
	[NUUDL_ValidFrom] ,
	[NUUDL_ValidTo] ,
	[NUUDL_IsCurrent] ,
	[NUUDL_ID] ,
	[NUUDL_CuratedBatchID] ,
	[NUUDL_CuratedProcessedTimestamp] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuudlNetCracker].[pimnrmlproductofferingpricechargekey_History]
WHERE DWIsCurrent = 1
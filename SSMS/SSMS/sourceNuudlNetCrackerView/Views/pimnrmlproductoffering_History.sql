
CREATE VIEW [sourceNuudlNetCrackerView].[pimnrmlproductoffering_History]
AS
SELECT 
	[available_from] ,
	[available_to] ,
	[localized_name_json_dan] ,
	[id] ,
	[is_active] ,
	[name] ,
	[product_family_id] ,
	[product_offering_charging_type] ,
	[sku_id] ,
	[tags_json__corrupt_record] ,
	[weight] ,
	[external_id] ,
	[extended_parameters_json__corrupt_record] ,
	[extended_parameters_json_deviceType] ,
	[extended_parameters_json_migrationId] ,
	[extended_parameters_json_mobileAddOnType] ,
	[extended_parameters_json_noInWarehouse] ,
	[extended_parameters_json_NumberInWarehouse] ,
	[extended_parameters_json_offeringBusinessType] ,
	[extended_parameters_json_offeringBusinessUse] ,
	[extended_parameters_json_phoneNumberOfferingType] ,
	[extended_parameters_json_simOfferingType] ,
	[extended_parameters_json_termsConditionsType] ,
	[tangible_product_id] ,
	[included_brand_json__corrupt_record] ,
	[included_customer_categories_json__corrupt_record] ,
	[included_distribution_channels_json__corrupt_record] ,
	[included_markets_json__corrupt_record] ,
	[excluded_markets] ,
	[excluded_customer_categories] ,
	[excluded_distribution_channels] ,
	[product_specification_id] ,
	[cdc_revision_id] ,
	[is_current] ,
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
FROM [sourceNuudlNetCracker].[pimnrmlproductoffering_History]
WHERE DWIsCurrent = 1
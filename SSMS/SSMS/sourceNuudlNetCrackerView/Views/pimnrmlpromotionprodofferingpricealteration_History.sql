
CREATE VIEW [sourceNuudlNetCrackerView].[pimnrmlpromotionprodofferingpricealteration_History]
AS
SELECT 
	[amount] ,
	[amount_percentage] ,
	[currency_id] ,
	[id] ,
	[name] ,
	[prod_offering_price_specification_id] ,
	[extended_parameters] ,
	[cdc_revision_id] ,
	[localized_name_json_dan] ,
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
FROM [sourceNuudlNetCracker].[pimnrmlpromotionprodofferingpricealteration_History]
WHERE DWIsCurrent = 1
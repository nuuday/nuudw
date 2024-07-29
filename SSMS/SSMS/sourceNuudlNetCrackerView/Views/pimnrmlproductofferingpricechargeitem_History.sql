
CREATE VIEW [sourceNuudlNetCrackerView].[pimnrmlproductofferingpricechargeitem_History]
AS
SELECT 
	[amount] ,
	[applied_from] ,
	[applied_to] ,
	[down_payment_amount] ,
	[id] ,
	[is_overridable] ,
	[price_key_id] ,
	[cdc_revision_id] ,
	[context_top_offering_ids_json__corrupt_record] ,
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
FROM [sourceNuudlNetCracker].[pimnrmlproductofferingpricechargeitem_History]
WHERE DWIsCurrent = 1
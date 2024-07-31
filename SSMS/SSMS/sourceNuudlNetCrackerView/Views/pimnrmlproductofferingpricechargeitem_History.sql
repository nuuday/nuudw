

CREATE VIEW [sourceNuudlNetCrackerView].[pimnrmlproductofferingpricechargeitem_History]
AS
SELECT 
	[amount] ,
	[applied_from] ,
	[applied_to] ,
	CAST([applied_from] AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' as datetime) [applied_from_CET],
	CAST([applied_to] AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' as datetime) [applied_to_CET],
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
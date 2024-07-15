
CREATE VIEW [sourceNuudlDawnView].[qssnrmlquoteitemprice_History]
AS
SELECT 
	[approx_installment_payment_amount_excluding_tax] ,
	[approx_installment_payment_amount_including_tax] ,
	[down_payment_overridden] ,
	[down_payment_value_excluding_tax] ,
	[down_payment_value_including_tax] ,
	[extended_parameters] ,
	[op] ,
	[overridden] ,
	[overridden_value] ,
	[override_type] ,
	[price_currency] ,
	[price_id] ,
	[price_plan_id] ,
	[price_specification_id] ,
	[price_type] ,
	[quote_id] ,
	[quote_item_id] ,
	[quote_version] ,
	[tax_rate] ,
	[ts_ms] ,
	[value_base_price_excluding_tax] ,
	[value_base_price_including_tax] ,
	[value_excluding_tax] ,
	[value_including_tax] ,
	[value_sub_total_price_excluding_tax] ,
	[value_sub_total_price_including_tax] ,
	[Snapshot] ,
	[Partition_Snapshot] ,
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
FROM [sourceNuudlDawn].[qssnrmlquoteitemprice_History]
WHERE DWIsCurrent = 1
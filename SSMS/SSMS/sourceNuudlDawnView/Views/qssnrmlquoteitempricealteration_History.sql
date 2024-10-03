

CREATE VIEW [sourceNuudlDawnView].[qssnrmlquoteitempricealteration_History]
AS
SELECT 
	[action] ,
	[application_duration] ,
	[application_mode] ,
	[duration_units] ,
	[extended_parameters] ,
	[id] ,
	[op] ,
	[overridden] ,
	[overridden_value] ,
	[override_type] ,
	[price_alteration_type] ,
	[price_type] ,
	[promo_action_id] ,
	[promo_pattern_id] ,
	[quote_id] ,
	[quote_item_id] ,
	[quote_version] ,
	[ts_ms] ,
	[valid_from] ,
	[valid_to] ,
	CAST([value_excluding_tax] as decimal(19,4)) [value_excluding_tax],
	CAST([value_including_tax] as decimal(19,4)) [value_including_tax],
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
FROM [sourceNuudlDawn].[qssnrmlquoteitempricealteration_History]
WHERE DWIsCurrent = 1
and NUUDL_DeleteType not like '%technical_delete%'
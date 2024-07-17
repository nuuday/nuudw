
CREATE VIEW [sourceNuudlDawnView].[qssnrmlquoteitem_History]
AS
SELECT 
	[account_id] ,
	[action] ,
	[active_from] ,
	[active_to] ,
	[amount] ,
	[approval_level] ,
	[availability_check_result] ,
	[business_action] ,
	[business_group_id] ,
	[business_group_name] ,
	[contracted_date] ,
	[creation_time] ,
	[delivery_item_id] ,
	[disconnection_reason] ,
	[distribution_channel_id] ,
	[extended_parameters] ,
	[geo_site_id] ,
	[id] ,
	[market_id] ,
	[marketing_bundle_id] ,
	[number_of_installments] ,
	[op] ,
	[parent_quote_item_id] ,
	[planned_disconnection_date] ,
	[product_instance_id] ,
	[product_offering_id] ,
	[product_specification_id] ,
	[product_specification_version] ,
	[quantity] ,
	[quote_id] ,
	[quote_version] ,
	[root_quote_item_id] ,
	[state] ,
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
FROM [sourceNuudlDawn].[qssnrmlquoteitem_History]
WHERE DWIsCurrent = 1
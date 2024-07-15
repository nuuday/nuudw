

CREATE VIEW [sourceNuudlDawnView].[ibsnrmlproductinstance_History]
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
	[eligibility_param_id] ,
	[expiration_date] ,
	[extended_attributes] ,	
	CASE 
		WHEN [extended_attributes] LIKE '%"Key"%' THEN REPLACE( REPLACE( REPLACE( REPLACE( REPLACE([extended_attributes],'[','') ,']','') ,'"key":','') ,',"value"','') ,'},{',',') 
		ELSE null
	END [extended_attributes_json],
	[extended_eligibility] ,
	[external_id] ,
	[id] ,
	[idempotency_key] ,
	[last_modified] ,
	[name] ,
	[number_of_installments] ,
	[offering_id] ,
	[op] ,
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
	[ts_ms] ,
	[type] ,
	[version] ,
	[NUUDL_RescuedData] ,
	[NUUDL_BaseSourceFilename] ,
	[NUUDL_BaseBatchID] ,
	[NUUDL_BaseProcessedTimestamp] ,
	[Snapshot] ,
	[Partition_Snapshot] ,
	[NUUDL_CuratedBatchID] ,
	[NUUDL_CuratedProcessedTimestamp] ,
	[NUUDL_CuratedSourceFilename] ,
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
FROM [sourceNuudlDawn].[ibsnrmlproductinstance_History]
WHERE DWIsCurrent = 1
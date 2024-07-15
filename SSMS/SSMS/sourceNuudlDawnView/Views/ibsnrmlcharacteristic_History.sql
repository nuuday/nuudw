
CREATE VIEW [sourceNuudlDawnView].[ibsnrmlcharacteristic_History]
AS
SELECT 
	[attribute_id] ,
	[name] ,
	[op] ,
	[product_instance_id] ,
	[product_offering_char_id] ,
	[product_spec_char_id] ,
	[ts_ms] ,
	[value] ,
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
FROM [sourceNuudlDawn].[ibsnrmlcharacteristic_History]
WHERE DWIsCurrent = 1
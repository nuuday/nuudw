
CREATE VIEW [sourceNuudlNetCrackerView].[ibsnrmlcharacteristic_History]
AS
SELECT 
	[name] ,
	[product_instance_id] ,
	[product_offering_char_id] ,
	[product_spec_char_id] ,
	[value_json__corrupt_record] ,
	[attribute_id] ,
	[is_deleted] ,
	[last_modified_ts] ,
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
FROM [sourceNuudlNetCracker].[ibsnrmlcharacteristic_History]
WHERE DWIsCurrent = 1
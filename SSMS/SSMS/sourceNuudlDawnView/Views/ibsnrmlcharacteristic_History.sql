

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
	CONVERT( NVARCHAR(20), TRIM(TRANSLATE( value, '["]', '   ' )) ) value,
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
FROM [sourceNuudlDawn].[ibsnrmlcharacteristic_History]
WHERE DWIsCurrent = 1
and NUUDL_DeleteType not like '%technical_delete%'
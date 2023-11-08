
CREATE VIEW [sourceNuudlNetCrackerView].[pimnrmlcustomercategory_History]
AS
SELECT 
	[localized_name_json_dan] ,
	[id] ,
	[name] ,
	[parent_customer_category_id] ,
	[external_id] ,
	[extended_parameters] ,
	[cdc_revision_id] ,
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
FROM [sourceNuudlNetCracker].[pimnrmlcustomercategory_History]
WHERE DWIsCurrent = 1

CREATE VIEW [sourceNuudlNetCrackerView].[pimnrmlprodofferingpricespecification_History]
AS
SELECT 
	[external_id] ,
	[id] ,
	[name] ,
	[price_type] ,
	[extended_parameters] ,
	[cdc_revision_id] ,
	[localized_name_json_dan] ,
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
FROM [sourceNuudlNetCracker].[pimnrmlprodofferingpricespecification_History]
WHERE DWIsCurrent = 1
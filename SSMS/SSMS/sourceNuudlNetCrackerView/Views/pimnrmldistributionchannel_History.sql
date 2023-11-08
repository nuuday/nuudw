
CREATE VIEW [sourceNuudlNetCrackerView].[pimnrmldistributionchannel_History]
AS
SELECT 
	[localized_name_json_dan] ,
	[id] ,
	[name] ,
	[extended_parameters_json_insurancePolicyPrefix] ,
	[extended_parameters_json_storeAddress] ,
	[external_id] ,
	[extended_parameters_json__corrupt_record] ,
	[extended_parameters_json_channelType] ,
	[extended_parameters_json_storeID] ,
	[extended_parameters_json_storeName] ,
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
FROM [sourceNuudlNetCracker].[pimnrmldistributionchannel_History]
WHERE DWIsCurrent = 1
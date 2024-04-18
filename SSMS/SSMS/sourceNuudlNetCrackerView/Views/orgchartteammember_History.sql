
CREATE VIEW [sourceNuudlNetCrackerView].[orgchartteammember_History]
AS
SELECT 
	[id] ,
	[idm_user_id] ,
	[external_id] ,
	[name] ,
	[first_name] ,
	[last_name] ,
	[start_date] ,
	[end_date] ,
	[skill] ,
	[position] ,
	[geographic_site] ,
	[is_deleted] ,
	[last_modified_ts] ,
	[is_current] ,
	[contact_medium_json_id] ,
	[contact_medium_json_mediumType] ,
	[contact_medium_json_notDeactivated] ,
	[contact_medium_json_potentiallyActive] ,
	[contact_medium_json_preferred] ,
	[contact_medium_json_preferredNotification] ,
	[distribution_channel_json__corrupt_record] ,
	[distribution_channel_json_default] ,
	[distribution_channel_json_id] ,
	[distribution_channel_json_isDefaultOrFalse] ,
	[distribution_channel_json_name] ,
	[idm_roles_json__corrupt_record] ,
	[contact_medium_json_characteristic_json_emailAddress] ,
	[contact_medium_json_validFor_json_endDateTime] ,
	[contact_medium_json_validFor_json_startDateTime] ,
	[NUUDL_ValidFrom] ,
	[NUUDL_ValidTo] ,
	[NUUDL_IsCurrent] ,
	[NUUDL_ID] ,
	[NUUDL_StandardizedProcessedTimestamp] ,
	[NUUDL_CuratedBatchID] ,
	[NUUDL_CuratedProcessedTimestamp] ,
	[NUUDL_CuratedSourceFilename] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuudlNetCracker].[orgchartteammember_History]
WHERE DWIsCurrent = 1
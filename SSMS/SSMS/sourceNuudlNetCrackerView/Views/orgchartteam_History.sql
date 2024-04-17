
CREATE VIEW [sourceNuudlNetCrackerView].[orgchartteam_History]
AS
SELECT 
	[id] ,
	[idm_team_id] ,
	[external_id] ,
	[name] ,
	[start_date] ,
	[end_date] ,
	[type] ,
	[territory] ,
	[business_calendar] ,
	[is_deleted] ,
	[last_modified_ts] ,
	[is_current] ,
	[contact_medium_json__corrupt_record] ,
	[contact_medium_json_id] ,
	[contact_medium_json_mediumType] ,
	[contact_medium_json_notDeactivated] ,
	[contact_medium_json_potentiallyActive] ,
	[contact_medium_json_preferred] ,
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
FROM [sourceNuudlNetCracker].[orgchartteam_History]
WHERE DWIsCurrent = 1
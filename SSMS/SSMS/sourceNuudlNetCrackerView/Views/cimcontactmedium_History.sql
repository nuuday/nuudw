
CREATE VIEW [sourceNuudlNetCrackerView].[cimcontactmedium_History]
AS
SELECT 
	[id] ,
	[city] ,
	[country] ,
	[email_address] ,
	[phone_ext_number] ,
	[fax_number] ,
	[postcode] ,
	[state_or_province] ,
	[street1] ,
	[street2] ,
	[type_of_contact] ,
	[type_of_contact_method] ,
	[is_active] ,
	[active_from] ,
	[ref_type] ,
	[ref_id] ,
	[extended_attributes_json__corrupt_record] ,
	[extended_attributes_json_careOf] ,
	[extended_attributes_json_district] ,
	[extended_attributes_json_floor] ,
	[extended_attributes_json_municipalityCode] ,
	[extended_attributes_json_namId] ,
	[extended_attributes_json_streetCode] ,
	[extended_attributes_json_suite] ,
	[contact_hour] ,
	[changed_by_json_userId] ,
	[start_date_time] ,
	[end_date_time] ,
	[preferred_contact] ,
	[preferred_notification] ,
	[billing_data_json__corrupt_record] ,
	[billing_data_json_addressFormat] ,
	[social_network_id] ,
	[is_deleted] ,
	[last_modified_ts] ,
	[active_to] ,
	[version] ,
	[is_current] ,
	[changed_by_json_userName] ,
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
FROM [sourceNuudlNetCracker].[cimcontactmedium_History]
WHERE DWIsCurrent = 1


CREATE VIEW [sourceNuudlDawnView].[cimcontactmedium_History]
AS
SELECT 
	[active_from] ,
	[billing_data] ,
	[changed_by] ,
	[city] ,
	[contact_hour] ,
	[country] ,
	[email_address] ,
	[end_date_time] ,
	[extended_attributes] ,
	[fax_number] ,
	[id] ,
	[is_active] ,
	[op] ,
	[phone_ext_number] ,
	[phone_number] ,
	[postcode] ,
	[preferred_contact] ,
	[preferred_notification] ,
	[push_notification_group_key] ,
	[ref_id] ,
	[ref_type] ,
	[social_network_id] ,
	[start_date_time] ,
	[state_or_province] ,
	[street1] ,
	[street2] ,
	[ts_ms] ,
	[type_of_contact] ,
	[type_of_contact_method] ,
	TRIM(TRANSLATE([extended_attributes_floor],'["]','   ')) [extended_attributes_floor],
	TRIM(TRANSLATE([extended_attributes_suite],'["]','   ')) [extended_attributes_suite],
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
FROM [sourceNuudlDawn].[cimcontactmedium_History]
WHERE DWIsCurrent = 1
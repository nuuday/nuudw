
CREATE VIEW [sourceNuudlDawnView].[cimcustomer_History]
AS
SELECT 
	[active_from] ,
	[billing_data] ,
	[billing_synchronization_status] ,
	[brand_id] ,
	[changed_by] ,
	[customer_category_id] ,
	[customer_number] ,
	[customer_since] ,
	[end_date_time] ,
	[engaged_party_description] ,
	[engaged_party_id] ,
	[engaged_party_name] ,
	[engaged_party_ref_type] ,
	[extended_attributes] ,
	[external_id] ,
	[id] ,
	[idempotency_key] ,
	[last_nps_survey_ref] ,
	[name] ,
	[net_promoter_score] ,
	[ola_ref] ,
	[op] ,
	[org_chart_ref] ,
	[portfolio] ,
	[start_date_time] ,
	[status] ,
	[status_reason] ,
	[ts_ms] ,
	[extended_attributes_brandName] ,
	[extended_attributes_employeeBrand] ,
	[extended_attributes_employeeId] ,
	[extended_attributes_migration_date] ,
	[extended_attributes_migration_phase] ,
	[extended_attributes_migration_source] ,
	[extended_attributes_migrationFlag] ,
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
FROM [sourceNuudlDawn].[cimcustomer_History]
WHERE DWIsCurrent = 1
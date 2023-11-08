
CREATE VIEW [sourceNuudlNetCrackerView].[cimcustomer_History]
AS
SELECT 
	[id] ,
	[active_from] ,
	[customer_category_id] ,
	[brand_id] ,
	[status] ,
	[status_reason] ,
	[name] ,
	[customer_number] ,
	[engaged_party_name] ,
	[engaged_party_description] ,
	[engaged_party_id] ,
	[engaged_party_ref_type] ,
	[external_id] ,
	[extended_attributes_json__corrupt_record] ,
	[extended_attributes_json_brandName] ,
	[extended_attributes_json_employeeBrand] ,
	[extended_attributes_json_employeeId] ,
	[changed_by_json_userName] ,
	[start_date_time] ,
	[end_date_time] ,
	[billing_synchronization_status] ,
	[customer_since] ,
	[billing_data_json_customerType] ,
	[idempotency_key] ,
	[fts] ,
	[portfolio] ,
	[ola_ref] ,
	[org_chart_ref] ,
	[last_nps_survey_ref] ,
	[net_promoter_score] ,
	[is_deleted] ,
	[last_modified_ts] ,
	[active_to] ,
	[version] ,
	[is_current] ,
	[changed_by_json_userId] ,
	[billing_data_json_invoicingCompany] ,
	[billing_data_json_customerPermission] ,
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
FROM [sourceNuudlNetCracker].[cimcustomer_History]
WHERE DWIsCurrent = 1
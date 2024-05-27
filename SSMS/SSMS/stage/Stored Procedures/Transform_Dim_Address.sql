
CREATE PROCEDURE [stage].[Transform_Dim_Address]
	@JobIsIncremental BIT			
AS 


-------------------------------------------------------------------------------
-- Fetching gross list
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS #gross_list

SELECT DISTINCT
	cm.id cimcontactmedium_id,
	CONCAT( 
		ISNULL( cm.Street1, '' ), 
		';', ISNULL( cm.Street2, '' ), 
		';', ISNULL( cm.[extended_attributes_json_floor], '' ), 
		';', ISNULL( cm.[extended_attributes_json_suite], '' ) , 
		';', ISNULL( cm.Postcode, '' ), 
		';', ISNULL( cm.City, '' )
	) AddressKey,
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( cm.Street1, '' ), '?' ) ) AS Street1,
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( cm.Street2, '' ), '?' ) ) AS Street2,
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( cm.Postcode, '' ), '?' ) ) AS Postcode,
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( cm.City, '' ), '?' ) ) AS City,
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( cm.[extended_attributes_json_floor], '' ), '?' ) ) AS [Floor],
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( cm.[extended_attributes_json_suite], '' ), '?' ) ) AS Suite,
	CONVERT( NVARCHAR(10), ISNULL( CAST(nam.sub_address_id as nvarchar), '?' ) )  AS NAMID,
	CONVERT( NVARCHAR(32), ISNULL( CAST(nam.sub_address_dar_id as nvarchar), '?' ) )  AS SubAddressDarID,
	CONVERT( NVARCHAR(32), ISNULL( CAST(nam.sub_address_mad_id as nvarchar), '?' ) )  AS SubAddressMadID,
	CONVERT( NVARCHAR(20), ISNULL( CAST(nam.sub_address_kvhx_id as nvarchar), '?' ) )  AS KvhxID
INTO #gross_list
FROM [sourceNuudlNetCrackerView].[cimcontactmedium_History] cm
LEFT JOIN SourceNuudlNAMView.nam_History nam 
	ON nam.address_city = cm.city
		AND nam.address_postcode = cm.postcode
		AND nam.address_street_name = cm.street1
		AND CONCAT(nam.address_street_no, coalesce(nam.address_street_no_suffix,'')) = cm.street2
		AND coalesce(nam.sub_address_floor,'') = coalesce(cm.extended_attributes_json_floor,'')
		AND coalesce(nam.sub_address_suite,'') = coalesce(cm.extended_attributes_json_suite,'')
		AND nam.sub_address_deleted = 0
WHERE
	cm.is_current = 1
	AND cm.type_of_contact_method = 'Billing contact details'
	AND 
	CONCAT( 
		ISNULL( cm.Street1, '' ), 
		ISNULL( cm.Street2, '' ), 
		ISNULL( cm.[extended_attributes_json_floor], '' ), 
		ISNULL( cm.[extended_attributes_json_suite], '' ) , 
		ISNULL( cm.Postcode, '' ), 
		ISNULL( cm.City, '' )
	) <> ''
	
-------------------------------------------------------------------------------
-- Identify errors 
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS #error_list
CREATE TABLE #error_list (
	cimcontactmedium_id nvarchar(36),
	ErrorMessage nvarchar(100)
)

INSERT INTO #error_list (cimcontactmedium_id, ErrorMessage)
SELECT cimcontactmedium_id, 'NAMID not found in master data from NAM'
FROM #gross_list
WHERE NAMID ='?'


-- Saving the latest result in an error table
TRUNCATE TABLE [sourceNuudlNetCracker].[cimcontactmedium_History_Error] 
INSERT INTO [sourceNuudlNetCracker].[cimcontactmedium_History_Error] (ErrorMessage, [id], [city], [country], [email_address], [phone_ext_number], [fax_number], [postcode], [state_or_province], [street1], [street2], [type_of_contact], [type_of_contact_method], [is_active], [active_from], [ref_type], [ref_id], [extended_attributes_json__corrupt_record], [extended_attributes_json_careOf], [extended_attributes_json_district], [extended_attributes_json_floor], [extended_attributes_json_municipalityCode], [extended_attributes_json_namId], [extended_attributes_json_streetCode], [extended_attributes_json_suite], [contact_hour], [changed_by_json_userId], [start_date_time], [end_date_time], [preferred_contact], [preferred_notification], [billing_data_json__corrupt_record], [billing_data_json_addressFormat], [social_network_id], [is_deleted], [last_modified_ts], [active_to], [version], [is_current], [changed_by_json_userName], [NUUDL_ValidFrom], [NUUDL_ValidTo], [NUUDL_IsCurrent], [NUUDL_ID], [NUUDL_CuratedBatchID], [DWIsCurrent], [DWValidFromDate], [DWValidToDate], [DWCreatedDate], [DWModifiedDate], [DWIsDeletedInSource], [DWDeletedInSourceDate])
SELECT el.ErrorMessage, [id], [city], [country], [email_address], [phone_ext_number], [fax_number], [postcode], [state_or_province], [street1], [street2], [type_of_contact], [type_of_contact_method], [is_active], [active_from], [ref_type], [ref_id], [extended_attributes_json__corrupt_record], [extended_attributes_json_careOf], [extended_attributes_json_district], [extended_attributes_json_floor], [extended_attributes_json_municipalityCode], [extended_attributes_json_namId], [extended_attributes_json_streetCode], [extended_attributes_json_suite], [contact_hour], [changed_by_json_userId], [start_date_time], [end_date_time], [preferred_contact], [preferred_notification], [billing_data_json__corrupt_record], [billing_data_json_addressFormat], [social_network_id], [is_deleted], [last_modified_ts], [active_to], [version], [is_current], [changed_by_json_userName], [NUUDL_ValidFrom], [NUUDL_ValidTo], [NUUDL_IsCurrent], [NUUDL_ID], [NUUDL_CuratedBatchID], [DWIsCurrent], [DWValidFromDate], [DWValidToDate], [DWCreatedDate], [DWModifiedDate], [DWIsDeletedInSource], [DWDeletedInSourceDate]
FROM [sourceNuudlNetCracker].[cimcontactmedium_History] cm
INNER JOIN #error_list el ON el.cimcontactmedium_id = cm.id
WHERE cm.NUUDL_IsCurrent = 1


-------------------------------------------------------------------------------
-- Update stage table 
-------------------------------------------------------------------------------

TRUNCATE TABLE [stage].[Dim_Address]

INSERT INTO stage.[Dim_Address] WITH (TABLOCK) (AddressKey, Street1, Street2, Postcode, City, [Floor], Suite, NAMID, SubAddressDarID, SubAddressMadID, KvhxID)
SELECT DISTINCT
	AddressKey,
	Street1,
	Street2,
	Postcode,
	City,
	[Floor],
	Suite,
	NAMID,
	SubAddressDarID,
	SubAddressMadID,
	KvhxID
FROM #gross_list gl
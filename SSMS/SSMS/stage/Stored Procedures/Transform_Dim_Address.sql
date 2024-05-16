
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
		';', ISNULL( cm.Postcode, '' ), 
		';', ISNULL( cm.City, '' ), 
		';', ISNULL( cm.[extended_attributes_json_floor], '' ), 
		';', ISNULL( cm.[extended_attributes_json_suite], '' ) 
	) AddressKey,
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( cm.Street1, '' ), '?' ) ) AS Street1,
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( cm.Street2, '' ), '?' ) ) AS Street2,
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( cm.Postcode, '' ), '?' ) ) AS Postcode,
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( cm.City, '' ), '?' ) ) AS City,
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( cm.[extended_attributes_json_floor], '' ), '?' ) ) AS [Floor],
	CONVERT( NVARCHAR(50), ISNULL( NULLIF( cm.[extended_attributes_json_suite], '' ), '?' ) ) AS Suite,
	CONVERT( NVARCHAR(10), ISNULL( NULLIF( cm.extended_attributes_json_namId, '' ), '?' ) )  AS NAMID
INTO #gross_list
FROM [sourceNuudlNetCrackerView].[cimcontactmedium_History] cm
WHERE
	cm.is_current = 1
	AND cm.type_of_contact_method = 'Billing contact details'
	AND 
	CONCAT( 
		ISNULL( cm.Street1, '' ), 
		ISNULL( cm.Street2, '' ), 
		ISNULL( cm.Postcode, '' ), 
		ISNULL( cm.City, '' ), 
		ISNULL( cm.[extended_attributes_json_floor], '' ), 
		ISNULL( cm.[extended_attributes_json_suite], '' ) 
	) <> ''



-------------------------------------------------------------------------------
-- Identify errors between addresses and NAMIDs
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS #error_list
CREATE TABLE #error_list (
	cimcontactmedium_id nvarchar(36),
	NAMID NVARCHAR(10),
	ErrorMessageId int,
	ErrorMessage nvarchar(100)
)


-- Identify IDs with no NAMID, eventhough an ID with the same address has an NAMID
INSERT INTO #error_list ( cimcontactmedium_id, NAMID, ErrorMessageId, ErrorMessage )
SELECT cimcontactmedium_id, NAMID, 1, 'Seems to be missing an NAMID'
FROM #gross_list
WHERE 
	AddressKey IN (
		SELECT AddressKey--, STRING_AGG(NAMID, ' | ') NAMIDs
		FROM #gross_list
		--WHERE NAMID <> '?'
		GROUP BY AddressKey
		HAVING COUNT(DISTINCT NAMID) = 2 AND MIN(NAMID) = '?'
	)
	AND NAMID = '?' 

-- Identify IDs with address that appear to have multiple NAMIDs associated
INSERT INTO #error_list ( cimcontactmedium_id, NAMID, ErrorMessageId, ErrorMessage )
SELECT cimcontactmedium_id, NAMID, 2, 'The address have multiple NAMIDs associated'
FROM #gross_list
WHERE 
	AddressKey IN (
		SELECT AddressKey--, STRING_AGG(NAMID, ' | ') NAMIDs
		FROM #gross_list
		WHERE NAMID <> '?'
		GROUP BY AddressKey
		HAVING COUNT(DISTINCT NAMID) > 1
	)


-- Identify IDs with NAMIDs that appear to have multiple addresses associated
INSERT INTO #error_list ( cimcontactmedium_id, NAMID, ErrorMessageId, ErrorMessage )
SELECT cimcontactmedium_id, NAMID, 3, 'The NAMID have multiple addresses associated'
FROM #gross_list
WHERE 
	NAMID IN (
		SELECT NAMID--, STRING_AGG(AddressKey, ' | ') AddressKeys
		FROM #gross_list
		WHERE NAMID <> '?'
		GROUP BY NAMID
		HAVING COUNT(DISTINCT AddressKey) > 1
	)

-- Saving the latest result in an error table
TRUNCATE TABLE [sourceNuudlNetCracker].[cimcontactmedium_History_Error] 
INSERT INTO [sourceNuudlNetCracker].[cimcontactmedium_History_Error] (ErrorMessage, [id], [city], [country], [email_address], [phone_ext_number], [fax_number], [postcode], [state_or_province], [street1], [street2], [type_of_contact], [type_of_contact_method], [is_active], [active_from], [ref_type], [ref_id], [extended_attributes_json__corrupt_record], [extended_attributes_json_careOf], [extended_attributes_json_district], [extended_attributes_json_floor], [extended_attributes_json_municipalityCode], [extended_attributes_json_namId], [extended_attributes_json_streetCode], [extended_attributes_json_suite], [contact_hour], [changed_by_json_userId], [start_date_time], [end_date_time], [preferred_contact], [preferred_notification], [billing_data_json__corrupt_record], [billing_data_json_addressFormat], [social_network_id], [is_deleted], [last_modified_ts], [active_to], [version], [is_current], [changed_by_json_userName], [NUUDL_ValidFrom], [NUUDL_ValidTo], [NUUDL_IsCurrent], [NUUDL_ID], [NUUDL_CuratedBatchID], [DWIsCurrent], [DWValidFromDate], [DWValidToDate], [DWCreatedDate], [DWModifiedDate], [DWIsDeletedInSource], [DWDeletedInSourceDate])
SELECT el.ErrorMessage, [id], [city], [country], [email_address], [phone_ext_number], [fax_number], [postcode], [state_or_province], [street1], [street2], [type_of_contact], [type_of_contact_method], [is_active], [active_from], [ref_type], [ref_id], [extended_attributes_json__corrupt_record], [extended_attributes_json_careOf], [extended_attributes_json_district], [extended_attributes_json_floor], [extended_attributes_json_municipalityCode], [extended_attributes_json_namId], [extended_attributes_json_streetCode], [extended_attributes_json_suite], [contact_hour], [changed_by_json_userId], [start_date_time], [end_date_time], [preferred_contact], [preferred_notification], [billing_data_json__corrupt_record], [billing_data_json_addressFormat], [social_network_id], [is_deleted], [last_modified_ts], [active_to], [version], [is_current], [changed_by_json_userName], [NUUDL_ValidFrom], [NUUDL_ValidTo], [NUUDL_IsCurrent], [NUUDL_ID], [NUUDL_CuratedBatchID], [DWIsCurrent], [DWValidFromDate], [DWValidToDate], [DWCreatedDate], [DWModifiedDate], [DWIsDeletedInSource], [DWDeletedInSourceDate]
FROM [sourceNuudlNetCracker].[cimcontactmedium_History] cm
INNER JOIN #error_list el ON el.cimcontactmedium_id = cm.id
WHERE cm.NUUDL_IsCurrent = 1



-------------------------------------------------------------------------------
-- Update stage table with addresses and excluding NAMIDs that appear in the error list
-------------------------------------------------------------------------------

TRUNCATE TABLE [stage].[Dim_Address]

INSERT INTO stage.[Dim_Address] WITH (TABLOCK) (AddressKey, Street1, Street2, Postcode, City, [Floor], Suite, NAMID)
SELECT DISTINCT
	AddressKey,
	Street1,
	Street2,
	Postcode,
	City,
	[Floor],
	Suite,
	CASE 
		WHEN EXISTS (SELECT * FROM #error_list WHERE NAMID = gl.NAMID AND ErrorMessageId IN (2,3)) THEN '?' /* Remove possible wrong NAMIDs */
		ELSE gl.NAMID
	END AS NAMID
FROM #gross_list gl
WHERE NOT EXISTS (SELECT * FROM #error_list WHERE cimcontactmedium_id = gl.cimcontactmedium_id AND ErrorMessageId IN (1)) /* Excluding null rows */ 
	--AND AddressKey = 'Abildvej;12;6800;Varde;;'
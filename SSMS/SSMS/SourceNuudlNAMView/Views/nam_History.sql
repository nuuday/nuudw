
CREATE VIEW [SourceNuudlNAMView].[nam_History]
AS
SELECT 
	[sub_address_id] ,
	[sub_address_floor] ,
	[sub_address_suite] ,
	[sub_address_dar_id] ,
	[sub_address_mad_id] ,
	[sub_address_kvhx_id] ,
	[sub_address_official] ,
	[sub_address_deleted] ,
	[address_id] ,
	[address_street_name] ,
	[address_street_no] ,
	[address_street_no_suffix] ,
	[address_postcode] ,
	[address_city] ,
	[address_municipality] ,
	[address_district] ,
	[address_region] ,
	[address_street_code] ,
	[address_region_code] ,
	[address_dar_id] ,
	[address_mad_id] ,
	[address_kvhx_id] ,
	[sub_address_kvhx_id_2] ,
	[address_official] ,
	[address_deleted] ,
	[NUUDL_BaseSourceFilename] ,
	[NUUDL_BaseBatchID] ,
	[NUUDL_BaseProcessedTimestamp] ,
	[Snapshot] ,
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
FROM [SourceNuudlNAM].[nam_History]
WHERE DWIsCurrent = 1
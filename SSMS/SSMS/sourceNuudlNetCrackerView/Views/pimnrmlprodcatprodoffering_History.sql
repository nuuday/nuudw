
CREATE VIEW [sourceNuudlNetCrackerView].[pimnrmlprodcatprodoffering_History]
AS
SELECT 
	[product_catalog_id] ,
	[product_offering_id] ,
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
FROM [sourceNuudlNetCracker].[pimnrmlprodcatprodoffering_History]
WHERE DWIsCurrent = 1
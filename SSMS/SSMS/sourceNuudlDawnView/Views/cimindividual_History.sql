
CREATE VIEW [sourceNuudlDawnView].[cimindividual_History]
AS
SELECT 
	[active_from] ,
	[billing_data] ,
	[birthdate] ,
	[changed_by] ,
	[country_of_birth] ,
	[death_date] ,
	[extended_attributes] ,
	[gender] ,
	[id] ,
	[idempotency_key] ,
	[location] ,
	[marital_status] ,
	[nationality] ,
	[op] ,
	[place_of_birth] ,
	[status] ,
	[ts_ms] ,
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
	,[NUUDL_IsDeleted]
	,[NUUDL_DeleteType]
	,[NUUDL_IsLatest]
FROM [sourceNuudlDawn].[cimindividual_History]
WHERE DWIsCurrent = 1
and NUUDL_DeleteType not like '%technical_delete%'
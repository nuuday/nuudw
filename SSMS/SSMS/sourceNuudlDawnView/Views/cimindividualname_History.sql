
CREATE VIEW [sourceNuudlDawnView].[cimindividualname_History]
AS
SELECT 
	[active_from] ,
	[aristocratic_title] ,
	[changed_by] ,
	[family_generation] ,
	[family_name] ,
	[family_name_prefix] ,
	[form_of_address] ,
	[formatted_name] ,
	[generation] ,
	[given_name] ,
	[id] ,
	[individual_id] ,
	[legal_name] ,
	[middle_name] ,
	[preferred_given_name] ,
	[qualifications] ,
	[ts_ms] ,
	[lsn] ,
	[op] ,
	[NUUDL_IsCurrent] ,
	[NUUDL_ValidFrom] ,
	[NUUDL_ValidTo] ,
	[NUUDL_CuratedBatchID] ,
	[NUUDL_CuratedProcessedTimestamp] ,
	[NUUDL_IsDeleted] ,
	[NUUDL_DeleteType] ,
	[NUUDL_ID] ,
	[NUUDL_IsLatest] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuudlDawn].[cimindividualname_History]
WHERE DWIsCurrent = 1

CREATE VIEW [sourceNuudlDawnView].[nrmcusthasproductkeyname_History]
AS
SELECT 
	[customer_ref] ,
	[name] ,
	[op] ,
	[product_seq] ,
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
	,lsn
FROM [sourceNuudlDawn].[nrmcusthasproductkeyname_History]
WHERE DWIsCurrent = 1
and ISNULL(NUUDL_DeleteType,'') <> 'technical_delete'
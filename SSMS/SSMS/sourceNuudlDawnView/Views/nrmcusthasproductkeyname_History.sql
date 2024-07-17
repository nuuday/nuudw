
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
FROM [sourceNuudlDawn].[nrmcusthasproductkeyname_History]
WHERE DWIsCurrent = 1
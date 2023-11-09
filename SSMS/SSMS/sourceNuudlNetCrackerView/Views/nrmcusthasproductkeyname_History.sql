
CREATE VIEW [sourceNuudlNetCrackerView].[nrmcusthasproductkeyname_History]
AS
SELECT 
	[customer_ref] ,
	[product_seq] ,
	[name] ,
	[is_current] ,
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
FROM [sourceNuudlNetCracker].[nrmcusthasproductkeyname_History]
WHERE DWIsCurrent = 1
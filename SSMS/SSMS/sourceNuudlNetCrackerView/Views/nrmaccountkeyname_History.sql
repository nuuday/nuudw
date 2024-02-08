
CREATE VIEW [sourceNuudlNetCrackerView].[nrmaccountkeyname_History]
AS
SELECT 
	[account_num] ,
	[name] ,
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
FROM [sourceNuudlNetCracker].[nrmaccountkeyname_History]
WHERE DWIsCurrent = 1
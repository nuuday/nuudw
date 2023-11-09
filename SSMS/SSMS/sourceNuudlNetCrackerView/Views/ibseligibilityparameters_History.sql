
CREATE VIEW [sourceNuudlNetCrackerView].[ibseligibilityparameters_History]
AS
SELECT 
	[id] ,
	[market_id] ,
	[distribution_channel_id] ,
	[customer_category_id] ,
	[brand_id] ,
	[is_deleted] ,
	[last_modified_ts] ,
	[is_current] ,
	[NUUDL_ValidTo] ,
	[NUUDL_ValidFrom] ,
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
FROM [sourceNuudlNetCracker].[ibseligibilityparameters_History]
WHERE DWIsCurrent = 1
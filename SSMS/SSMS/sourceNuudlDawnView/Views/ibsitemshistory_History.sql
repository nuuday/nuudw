





CREATE VIEW [sourceNuudlDawnView].[ibsitemshistory_History]
AS
SELECT 
	a.[active_from] ,
	a.[active_to] ,
	CAST(a.active_from AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' as datetime) [active_from_CET],
	CAST(a.[active_to] AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' as datetime) [active_to_CET],
	a.[id] ,
	a.[idempotency_key] ,
	a.[is_snapshot] ,
	a.[item] ,
	a.[last_modified_ts] ,
	a.[op] ,
	a.[schema_version] ,
	a.[state] ,
	a.[ts_ms] ,
	a.[version] ,
	a.[is_deleted] ,
	a.[is_current] ,
	a.[item_accountRef] ,
	a.[item_customerId] ,
	a.[item_distributionChannelId] ,
	a.[item_expirationDate] ,
	CAST(CAST(a.[item_expirationDate] as datetime2(0)) AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' as datetime2(0)) [item_expirationDate_CET],
	a.[item_name] ,
	a.[item_offeringId] ,
	a.[item_offeringName] ,
	a.[item_parentId] ,
	a.[item_prices] ,
	a.[item_productFamilyId] ,
	a.[item_productFamilyName] ,
	a.[item_productSpecificationRef] ,
	a.[item_quantity] ,
	a.[item_quoteId] ,
	a.[item_relatedPartyRef] ,
	a.[item_rootId] ,
	a.[item_type] ,
	a.[item_version] ,
	a.[NUUDL_CuratedBatchID] ,
	a.[NUUDL_CuratedProcessedTimestamp] ,
	a.[NUUDL_IsCurrent] ,
	a.[NUUDL_ValidFrom] ,
	a.[NUUDL_ValidTo] ,
	a.[NUUDL_ID] 
	,a.[DWIsCurrent]
	,a.[DWValidFromDate]
	,a.[DWValidToDate]
	,a.[DWCreatedDate]
	,a.[DWModifiedDate]
	,a.[DWIsDeletedInSource]
	,a.[DWDeletedInSourceDate]
FROM [sourceNuudlDawn].[ibsitemshistory_History] a
LEFT JOIN [sourceNuudlDawn].[ibsitemshistory_History_Filter] b ON b.id = a.id
WHERE a.DWIsCurrent = 1
	AND b.id IS NULL






CREATE VIEW [sourceNuudlDawnView].[ibsitemshistorycharacteristics_History]
AS
SELECT
	a.[id],
	a.technology,
	a.international_phone_number,
	a.[NUUDL_CuratedBatchID],
	a.[NUUDL_IsCurrent],
	a.[NUUDL_ValidFrom],
	a.[NUUDL_ValidTo],
	a.[NUUDL_ID],
	a.[DWIsCurrent],
	a.[DWValidFromDate],
	a.[DWValidToDate],
	a.[DWCreatedDate],
	a.[DWModifiedDate],
	a.[DWIsDeletedInSource],
	a.[DWDeletedInSourceDate]
	,a.[NUUDL_IsDeleted]
	,a.[NUUDL_DeleteType]
	,a.[NUUDL_IsLatest]
FROM [sourceNuudlDawn].[ibsitemshistorycharacteristics_History] a
WHERE
	a.DWIsCurrent = 1
	and NUUDL_DeleteType not like '%technical_delete%'
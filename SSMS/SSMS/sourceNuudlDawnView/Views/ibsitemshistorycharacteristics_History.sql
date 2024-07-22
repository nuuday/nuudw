




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
FROM [sourceNuudlDawn].[ibsitemshistorycharacteristics_History] a
WHERE
	a.DWIsCurrent = 1
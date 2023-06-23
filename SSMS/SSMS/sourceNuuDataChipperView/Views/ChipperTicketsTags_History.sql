
CREATE VIEW [sourceNuuDataChipperView].[ChipperTicketsTags_History]
AS
SELECT 
	[id] ,
	[tags] ,
	[sourceFilename] ,
	[processedTimestamp] ,
	[hour] ,
	[quarterhour] ,
	[SRC_DWSourceFilePath] ,
	[SRC_DWIsCurrent] ,
	[SRC_DWValidFromDate] ,
	[SRC_DWValidToDate] ,
	[SRC_DWCreatedDate] ,
	[SRC_DWModifiedDate] ,
	[SRC_DWIsDeletedInSource] ,
	[SRC_DWDeletedInSourceDate] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuuDataChipper].[ChipperTicketsTags_History]
WHERE DWIsCurrent = 1 AND SRC_DWIsCurrent = 1
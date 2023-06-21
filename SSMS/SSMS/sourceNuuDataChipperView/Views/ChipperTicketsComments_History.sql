
CREATE VIEW [sourceNuuDataChipperView].[ChipperTicketsComments_History]
AS
SELECT 
	[comments.author] ,
	[comments.text] ,
	[comments.timestamp] ,
	[id] ,
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
FROM [sourceNuuDataChipper].[ChipperTicketsComments_History]
WHERE DWIsCurrent = 1
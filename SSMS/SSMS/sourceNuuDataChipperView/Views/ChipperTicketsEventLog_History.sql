
CREATE VIEW [sourceNuuDataChipperView].[ChipperTicketsEventLog_History]
AS
SELECT 
	[eventLog.eventType] ,
	[eventLog.source.applicationId] ,
	[eventLog.source.userId] ,
	[id] ,
	[eventLog.timestamp] ,
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
	[SRC_DWDeletedInSourceDate] ,
	[eventLog.source.error.userId] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuuDataChipper].[ChipperTicketsEventLog_History]
WHERE DWIsCurrent = 1 AND SRC_DWIsCurrent = 1
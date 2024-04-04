CREATE VIEW [dimView].[OrderEvent] 
AS
SELECT
	[OrderEventID]
	,[OrderEventKey] AS [OrderEventKey]
	,[OrderEventName] AS [OrderEventName]
	,[SourceEventName] AS [SourceEventName]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[OrderEvent]
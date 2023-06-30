CREATE VIEW [dimView].[FAM Sales Channel] 
AS
SELECT
	[FAM_SalesChannelID]
	,[FAM_SalesChannelKey] AS [FAM Sales Channel Key]
	,[SalesChannelName] AS [Sales Channel Name]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[FAM_SalesChannel]
CREATE VIEW [dimView].[Technology] 
AS
SELECT
	[TechnologyID]
	,[TechnologyKey] AS [TechnologyKey]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[Technology]
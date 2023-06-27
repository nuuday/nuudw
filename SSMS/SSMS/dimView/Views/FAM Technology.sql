CREATE VIEW [dimView].[FAM Technology] 
AS
SELECT
	[FAM_TechnologyID]
	,[FAM_TechnologyKey] AS [F A M_ Technology Key]
	,[TechnologyName] AS [Technology Name]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[FAM_Technology]
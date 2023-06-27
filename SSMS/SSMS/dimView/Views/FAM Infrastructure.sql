CREATE VIEW [dimView].[FAM Infrastructure] 
AS
SELECT
	[FAM_InfrastructureID]
	,[FAM_InfrastructureKey] AS [F A M_ Infrastructure Key]
	,[InfrastructureName] AS [Infrastructure Name]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[FAM_Infrastructure]
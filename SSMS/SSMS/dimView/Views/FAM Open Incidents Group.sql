CREATE VIEW [dimView].[FAM Open Incidents Group] 
AS
SELECT
	[FAM_OpenIncidentsGroupID]
	,[FAM_OpenIncidentsGroupKey] AS [F A M_ Open Incidents Group Key]
	,[OpenIncidentsGroup] AS [Open Incidents Group]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[FAM_OpenIncidentsGroup]
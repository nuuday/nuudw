CREATE VIEW [dimView].[Employee] 
AS
SELECT
	[EmployeeID]
	,[EmployeeKey] AS [EmployeeKey]
	,[EmployeeName] AS [EmployeeName]
	,[EmployeeEmail] AS [EmployeeEmail]
	,[OrganizationalLevel1] AS [OrganizationalLevel1]
	,[OrganizationalLevel2] AS [OrganizationalLevel2]
	,[OrganizationalLevel3] AS [OrganizationalLevel3]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[Employee]
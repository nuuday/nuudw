

CREATE VIEW [martView_PRX].[DimEmployee]
AS
SELECT 
	[EmployeeID],
	[EmployeeKey],
	[EmployeeName],
	[EmployeeEmail],
	[OrganizationalLevel1],
	[OrganizationalLevel2],
	[OrganizationalLevel3],
	DWValidFromDate,
	DWValidToDate,
	DWIsCurrent,
	DWIsDeleted
FROM [dimView].[Employee]
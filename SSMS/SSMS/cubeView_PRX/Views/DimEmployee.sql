CREATE VIEW cubeView_PRX.DimEmployee
AS
SELECT
	[EmployeeID],
	[EmployeeKey],
	[EmployeeName],
	[EmployeeEmail],
	[OrganizationalLevel1],
	[OrganizationalLevel2],
	[OrganizationalLevel3]
FROM [dim].[Employee]
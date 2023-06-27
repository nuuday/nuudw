
CREATE VIEW cubeView_FAM.[Dim Employee]
AS
SELECT 
	[Legacy_EmployeeID] AS [EmployeeID],
	[Legacy Employee Key] AS [Employee Key],
	[Employee First Name],
	[Employee Last Name],
	[Employee Name],
	[Employee User Code],
	[Termination Date],
	[Employee Department Description Short],
	[Employee Organization Code]
FROM [dimView].[Legacy Employee]
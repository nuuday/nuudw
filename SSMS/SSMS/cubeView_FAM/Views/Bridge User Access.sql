
CREATE VIEW cubeView_FAM.[Bridge User Access]
AS
SELECT
	[Legacy_EmployeeID] AS [EmployeeID],
	[TopManager],
	[EmployeeName],
	[UserName]
FROM [bridgeView].[User Access]
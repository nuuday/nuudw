
CREATE VIEW cubeView_FAM.[Bridge User Access]
AS
SELECT
	[Legacy_EmployeeID],
	[TopManager],
	[EmployeeName],
	[UserName]
FROM [bridgeView].[User Access]
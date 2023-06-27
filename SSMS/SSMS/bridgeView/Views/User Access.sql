CREATE VIEW [bridgeView].[User Access] 
AS
SELECT
	[Legacy_EmployeeID]
	,[TopManager]
	,[EmployeeName]
	,[UserName]
	,[DWCreatedDate]
	,[DWModifiedDate]
	
FROM [bridge].[UserAccess]
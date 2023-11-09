CREATE VIEW [dimView].[HouseHold] 
AS
SELECT
	[HouseHoldID]
	,[HouseHoldkey] AS [HouseHoldkey]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[HouseHold]
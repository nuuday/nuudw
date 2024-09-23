
CREATE VIEW [martView_PRX].[DimHouseHold]
AS
SELECT 
	[HouseHoldID],
	[HouseHoldKey],
	DWValidFromDate,
	DWValidToDate,
	DWIsCurrent,
	DWIsDeleted
FROM [dimView].[HouseHold]
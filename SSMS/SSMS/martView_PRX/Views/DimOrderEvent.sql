
CREATE VIEW [martView_PRX].[DimOrderEvent]
AS
SELECT 
	[OrderEventID],
	[OrderEventKey],
	[OrderEventName],
	[SourceEventName],
	DWValidFromDate,
	DWValidToDate,
	DWIsCurrent,
	DWIsDeleted
FROM [dimView].[OrderEvent]
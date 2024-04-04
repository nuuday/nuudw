
CREATE VIEW [martView_PRX].[DimOrderEvent]
AS
SELECT 	[OrderEventID],	[OrderEventKey],	[OrderEventName],	[SourceEventName]
FROM [dimView].[OrderEvent]
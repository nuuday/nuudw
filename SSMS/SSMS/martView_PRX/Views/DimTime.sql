CREATE VIEW [martView_PRX].[DimTime]
AS
SELECT 
	[TimeID]
	,[TimeKey]
	,[TimeNotation] 
	,TimeHour
	,TimeMinute
FROM [dimView].[Time]
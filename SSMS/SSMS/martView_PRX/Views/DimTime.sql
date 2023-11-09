

CREATE VIEW [martView_PRX].[DimTime]
AS
SELECT 
	[TimeID],

	[TimeKey],
	[TimeDayPart],
	[TimeHourFromTo],
	[TimeNotation]
FROM [dimView].[Time]

CREATE VIEW [martView_PRX].[DimTime]
AS
SELECT 	[TimeID],	[TimeHourKey],	[TimeMinuteKey],	[Time],	[TimeDayPart],	[TimeHourFromTo],	[TimeNotation]
FROM [dimView].[Time]
CREATE VIEW dimView.Time 
AS
SELECT 
	[TimeID]
	,[TimeKey]
	,[TimeDayPart]
	,[TimeHourFromTo]
	,[TimeNotation] 
FROM dim.Time
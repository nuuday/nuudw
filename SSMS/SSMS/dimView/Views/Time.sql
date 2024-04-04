CREATE VIEW dimView.Time 
AS
SELECT 
	[TimeID]
	,[TimeKey]
	,[TimeNotation] 
	,TimeHour
	,TimeMinute
FROM dim.Time
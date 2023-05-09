
CREATE FUNCTION [meta].[GetEasterDaysFromYear]
(	
	@year INT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		meta.GetEasterSundayFromYear(@year)		
												AS [CalendarDate]
		,'Easter'								AS [EasterDayUKName]
		,'Påske'								AS [EasterDayDKName]

	UNION

	SELECT 
		DATEADD(DD,-2,meta.GetEasterSundayFromYear(@year))
												AS [CalendarDate]
		,'Good Friday' as [EasterDayUKName]
		,'Langfredag' as [EasterDayDKName]

	UNION

	SELECT 
		DATEADD(DD,-3,meta.GetEasterSundayFromYear(@year))
												AS [CalendarDate]
		,'Easter Thursday'						AS [EasterDayUKName]
		,'Skærtorsdag'							AS [EasterDayDKName]

	UNION

	SELECT 
		DATEADD(DD,1,meta.GetEasterSundayFromYear(@year))
												AS [CalendarDate]
		,'Easter Monday'						AS [EasterDayUKName]
		,'Påske mandag'							AS [EasterDayDKName]
)
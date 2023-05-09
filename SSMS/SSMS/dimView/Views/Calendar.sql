﻿CREATE VIEW dimView.Calendar AS

SELECT
	[CalendarID]
      ,[CalendarKey]
      ,[CalendarDate]
      ,[DayNumber]
      ,[WeekCode]
      ,[WeekNumber]
      ,[WeekName]
      ,[WeekYear]
      ,[WeekDayNumber]
      ,[WeekDayName]
      ,[MonthCode]
      ,[MonthNumber]
      ,[MonthName]
      ,[MonthShort]
      ,[MonthLong]
      ,[QuarterCode]
      ,[QuarterNumber]
      ,[QuarterName]
      ,[Quarter]
      ,[Year]
      ,[FiscalMonthCode]
      ,[FiscalMonthNumber]
      ,[FiscalMonthName]
      ,[FiscalQuarterCode]
      ,[FiscalQuarterNumber]
      ,[FiscalQuarterName]
      ,[FiscalYear]
      ,[FiscalYearName]
      ,[FirstDateofYear]
      ,[LastDateofYear]
      ,[FirstDateofQuarter]
      ,[LastDateofQuarter]
      ,[FirstDateofMonth]
      ,[LastDateofMonth]
      ,[FirstDateofWeek]
      ,[LastDateofWeek]
      ,[CurrentYear]
      ,[CurrentQuarter]
      ,[CurrentMonth]
      ,[CurrentWeek]
      ,[CurrentDay]
      ,[IsToday]
      ,[IsWeekend]
      ,[IsHoliday]
      ,[HolidayName]
      ,[SpecialDays]
      ,[CalendarIsFutureFlag]
	FROM dim.Calendar
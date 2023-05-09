CREATE PROCEDURE [meta].[CreateCalendarDimension] AS

BEGIN
	SET NOCOUNT ON;
	SET DATEFIRST 1;

	DECLARE 
		@start_date DATETIME,
		@end_date DATETIME,
		@MaxDate DATETIME,
		@FiscalEndMonth INT = 9,
		@UnknownDate VARCHAR(8) = '19000101',
		@YearFirst INT = 2010,
		@YearsAhead INT = 4;				-- @YearsAhead=3 <=> eg. Current year=2019 => Last year in calendar=2022

	-- Drop calendar dimension table
	IF OBJECT_ID('dim.Calendar', 'u') IS NULL BEGIN

	-- Create calendar dimension table
	CREATE TABLE dim.Calendar (
		[CalendarID] INT PRIMARY KEY,
		[CalendarKey] DATE,
		[CalendarDate] DATE NULL ,

		[DayNumber] INT NULL,

		[WeekCode] INT NULL,  
		[WeekNumber] INT NULL, 
		[WeekName] NVARCHAR(20) NULL,
		[WeekYear] INT NULL,

		[WeekDayNumber] SMALLINT NULL,
		[WeekDayName] NVARCHAR(10) NULL,

		[MonthCode] INT NULL,  
		[MonthNumber] INT NULL, 
		[MonthName] NVARCHAR(20) NULL,
		[MonthShort] NVARCHAR(3) NULL,
		[MonthLong] NVARCHAR(12) NULL,

		[QuarterCode] INT NULL,  
		[QuarterNumber] INT NULL, 
		[QuarterName] NVARCHAR(20) NULL,
		[Quarter] NVARCHAR(2) NULL,

		[Year] INT NULL,

		[FiscalMonthCode] INT NULL,  
		[FiscalMonthNumber] INT NULL, 
		[FiscalMonthName] NVARCHAR(20) NULL,

		[FiscalQuarterCode] INT NULL,  
		[FiscalQuarterNumber] INT NULL, 
		[FiscalQuarterName] NVARCHAR(20) NULL,

		[FiscalYear] INT NULL,
		[FiscalYearName] VARCHAR(10) NULL,

		[FirstDateofYear] DATE NULL,
		[LastDateofYear] DATE NULL,
		[FirstDateofQuarter] DATE NULL,
		[LastDateofQuarter] DATE NULL,
		[FirstDateofMonth] DATE NULL,
		[LastDateofMonth] DATE NULL,
		[FirstDateofWeek] DATE NULL,
		[LastDateofWeek] DATE NULL,

		[CurrentYear] SMALLINT NULL,
		[CurrentQuarter] SMALLINT NULL,
		[CurrentMonth] SMALLINT NULL,
		[CurrentWeek] SMALLINT NULL,
		[CurrentDay] INT NULL,

		[IsToday] BIT NULL,
		[IsWeekend] BIT NULL,
		[IsHoliday] BIT NULL,
		[HolidayName] VARCHAR(20) NULL,
		[SpecialDays] VARCHAR(20) NULL,
		[CalendarIsFutureFlag] BIT NULL,
		[DWModifiedDate] DATETIME
	) 

	END

	DROP TABLE IF EXISTS #Calendar
	
		SELECT * INTO #Calendar FROM dim.Calendar WHERE 1 = 2

	IF NOT EXISTS (SELECT * FROM dim.Calendar WHERE CalendarID = 19000101)

		BEGIN

	-- Insert unknown member
			INSERT INTO #Calendar (
				[CalendarID],
				[CalendarKey],
				[CalendarDate]
			)
			SELECT 
				@UnknownDate	AS [CalendarID],
				@UnknownDate	AS [CalendarKey],
				@UnknownDate	AS [CalendarDate]
		END

	-- Insert data
	SET @start_date = IIF((SELECT MIN(CalendarID) FROM dim.Calendar) IS NULL,DATEFROMPARTS(@YearFirst,1,1),(SELECT MAX(CalendarKey) FROM dim.Calendar))
	SET @end_date	= DATEFROMPARTS(@YearsAhead+YEAR(GETDATE()),12,31)

	WHILE @start_date <= @end_date AND @start_date <> @end_date
	BEGIN
		INSERT INTO #Calendar (
			[CalendarID],
			[CalendarKey],
			[CalendarDate]
		)
		SELECT
			[CalendarID]= CONVERT(INT,CONVERT(VARCHAR(8), @start_date,112)),
			[CalendarKey] = @start_date,
			[CalendarDate] = @start_date
		
		SET @start_date = DATEADD(dd, 1, @start_date);
	END;

	-- Update Columns
	UPDATE #Calendar
	SET [DayNumber] = DATEPART(dd,[CalendarDate]),
		-- Week
		[WeekCode] = CONVERT(VARCHAR,DATEPART(YY,[CalendarDate])) + RIGHT('0'+ CONVERT(VARCHAR,DATEPART(ISO_WEEK,[CalendarDate])),2),
		[WeekNumber] = DATEPART(ISO_WEEK,[CalendarDate]),
		[WeekYear] = DATEPART(YY,[CalendarDate]),
		[WeekName] = 'Week '+ RIGHT('0'+ CONVERT(VARCHAR,DATEPART(ISO_WEEK,[CalendarDate])),2) + ', ' + CONVERT(VARCHAR,DATEPART(YY,[CalendarDate])),
		[WeekDayNumber] = DATEPART(dw,[CalendarDate]),
		[WeekDayName] =
		CASE DATEPART(dw,[CalendarDate])
			WHEN 1 THEN 'Monday'
			WHEN 2 THEN 'Tuesday'
			WHEN 3 THEN 'Wednesday'
			WHEN 4 THEN 'Thursday'
			WHEN 5 THEN 'Friday'
			WHEN 6 THEN 'Saturday'
			WHEN 7 THEN 'Sunday'
		END,
		-- Month
		[MonthCode] = 100*DATEPART(yy,[CalendarDate])+DATEPART(mm,[CalendarDate]),
		[MonthNumber] = MONTH([CalendarDate]), 
		[MonthName] =
			CASE DATEPART(MM,[CalendarDate])
				WHEN 1 THEN 'January'
				WHEN 2 THEN 'February'
				WHEN 3 THEN 'March'
				WHEN 4 THEN 'April'
				WHEN 5 THEN 'May'
				WHEN 6 THEN 'June'
				WHEN 7 THEN 'July'
				WHEN 8 THEN 'August'
				WHEN 9 THEN 'September'
				WHEN 10 THEN 'October'
				WHEN 11 THEN 'November'
				WHEN 12 THEN 'December'
			END + ', '+ CONVERT(VARCHAR,DATENAME(YEAR,[CalendarDate])),
		[MonthShort] =
			CASE DATEPART(MM,[CalendarDate])
				WHEN 1 THEN 'Jan'
				WHEN 2 THEN 'Feb'
				WHEN 3 THEN 'Mar'
				WHEN 4 THEN 'Apr'
				WHEN 5 THEN 'May'
				WHEN 6 THEN 'Jun'
				WHEN 7 THEN 'Jul'
				WHEN 8 THEN 'Aug'
				WHEN 9 THEN 'Sep'
				WHEN 10 THEN 'Oct'
				WHEN 11 THEN 'Nov'
				WHEN 12 THEN 'Dec'
			END,
		[MonthLong] =
			CASE DATEPART(MM,[CalendarDate])
				WHEN 1 THEN 'January'
				WHEN 2 THEN 'February'
				WHEN 3 THEN 'March'
				WHEN 4 THEN 'April'
				WHEN 5 THEN 'May'
				WHEN 6 THEN 'June'
				WHEN 7 THEN 'July'
				WHEN 8 THEN 'August'
				WHEN 9 THEN 'September'
				WHEN 10 THEN 'October'
				WHEN 11 THEN 'November'
				WHEN 12 THEN 'December'
			END,
		-- Quarter
		[QuarterCode] = 100*DATEPART(yy,[CalendarDate])+DATEPART(qq,[CalendarDate]),
		[QuarterNumber] = DATEPART(qq,[CalendarDate]),
		[QuarterName] = 'Q'+CONVERT(VARCHAR,DATENAME(QUARTER,[CalendarDate])) + ', ' + CONVERT(VARCHAR,DATENAME(YEAR,[CalendarDate])),
		[Quarter] = 'Q'+CONVERT(VARCHAR,DATENAME(QUARTER,[CalendarDate])),
		-- Year
		[Year] = DATEPART(yy,[CalendarDate]),
		-- Fiscal
		[FiscalMonthCode] = 100*DATEPART(yy,DATEADD(MM,-@FiscalEndMonth,[CalendarDate]))+DATEPART(mm,DATEADD(MM,-@FiscalEndMonth,[CalendarDate])),
		[FiscalMonthNumber] = DATEPART(MM,DATEADD(MM,-@FiscalEndMonth,[CalendarDate])),
		[FiscalMonthName] = CASE DATEPART(MM,[CalendarDate])
				WHEN 1 THEN 'January'
				WHEN 2 THEN 'February'
				WHEN 3 THEN 'March'
				WHEN 4 THEN 'April'
				WHEN 5 THEN 'May'
				WHEN 6 THEN 'June'
				WHEN 7 THEN 'July'
				WHEN 8 THEN 'August'
				WHEN 9 THEN 'September'
				WHEN 10 THEN 'October'
				WHEN 11 THEN 'November'
				WHEN 12 THEN 'December'
			END + ', '+ 
			CASE WHEN MONTH([CalendarDate]) <= @FiscalEndMonth 
				THEN CAST(YEAR(DATEADD(YY,-1,[CalendarDate])) AS VARCHAR)
				ELSE CAST(YEAR([CalendarDate]) AS NVARCHAR)
			END+'/'+CASE WHEN MONTH([CalendarDate]) <= @FiscalEndMonth 
				THEN SUBSTRING(CAST(YEAR([CalendarDate]) AS NVARCHAR),3,2)
				ELSE SUBSTRING(CAST(YEAR(DATEADD(YY,1,[CalendarDate])) AS VARCHAR),3,2)
			END,
		[FiscalQuarterCode] = 100*DATEPART(yy,DATEADD(MM,-@FiscalEndMonth,[CalendarDate]))+DATEPART(qq,DATEADD(MM,-@FiscalEndMonth,[CalendarDate])),
		[FiscalQuarterNumber] = DATEPART(QQ,DATEADD(MM,-@FiscalEndMonth,[CalendarDate])),
		[FiscalQuarterName] = 'Q'+CONVERT(VARCHAR,DATENAME(QUARTER,DATEADD(MM,-@FiscalEndMonth,[CalendarDate]))) + ', '+
			CASE WHEN MONTH([CalendarDate]) <= @FiscalEndMonth 
				THEN CAST(YEAR(DATEADD(YY,-1,[CalendarDate])) AS VARCHAR)
				ELSE CAST(YEAR([CalendarDate]) AS NVARCHAR)
			END+'/'+CASE WHEN MONTH([CalendarDate]) <= @FiscalEndMonth 
				THEN SUBSTRING(CAST(YEAR([CalendarDate]) AS NVARCHAR),3,2)
				ELSE SUBSTRING(CAST(YEAR(DATEADD(YY,1,[CalendarDate])) AS VARCHAR),3,2)
			END,
		[FiscalYear] = CASE WHEN MONTH([CalendarDate]) <= @FiscalEndMonth 
			THEN CAST(CAST(YEAR(DATEADD(YY,-1,[CalendarDate])) AS VARCHAR) AS INT) 
			ELSE CAST(CAST(YEAR([CalendarDate]) AS NVARCHAR) AS INT) 
		END,
		[FiscalYearName] = CASE WHEN MONTH([CalendarDate]) <= @FiscalEndMonth 
			THEN CAST(YEAR(DATEADD(YY,-1,[CalendarDate])) AS VARCHAR)
			ELSE CAST(YEAR([CalendarDate]) AS NVARCHAR)
		END+'/'+CASE WHEN MONTH([CalendarDate]) <= @FiscalEndMonth 
			THEN SUBSTRING(CAST(YEAR([CalendarDate]) AS NVARCHAR),3,2)
			ELSE SUBSTRING(CAST(YEAR(DATEADD(YY,1,[CalendarDate])) AS VARCHAR),3,2)
		END,

		-- First & Last
		[FirstDateofYear] = CAST(CAST(YEAR([CalendarDate]) AS VARCHAR(4)) + '-01-01' AS DATE),
		[LastDateofYear] = CAST(CAST(YEAR([CalendarDate]) AS VARCHAR(4)) + '-12-31' AS DATE),
		[FirstDateofQuarter] = DATEADD(qq,DATEDIFF(qq,0,[CalendarDate]), 0),
		[LastDateofQuarter] = DATEADD(dd,-1,DATEADD(qq,DATEDIFF(qq,0,[CalendarDate])+1,0)),
		[FirstDateofMonth] = CAST(CAST(YEAR([CalendarDate]) AS VARCHAR(4))+'-'+CAST(MONTH([CalendarDate]) AS VARCHAR(2))+'-01' AS DATE),
		[LastDateofMonth] = EOMONTH([CalendarDate]),
		[FirstDateofWeek] = DATEADD(dd,-(DATEPART(dw,@start_date)-1),[CalendarDate]),
		[LastDateofWeek] = DATEADD(dd,7-(DATEPART(dw,@start_date)),[CalendarDate]),
		[CurrentYear] = DATEDIFF(yy,GETDATE(),[CalendarDate]),
		[CurrentQuarter] = DATEDIFF(q,GETDATE(),[CalendarDate]),
		[CurrentMonth] = DATEDIFF(m,GETDATE(),[CalendarDate]),
		[CurrentWeek] = DATEDIFF(ww,GETDATE(),DATEADD(day,-1,[CalendarDate])),
		[CurrentDay] = DATEDIFF(dd,GETDATE(),[CalendarDate]),
		[IsToday] = 0,
		[IsWeekend] = 
		CASE DATEPART(dw,[CalendarDate])
			WHEN 1 THEN 0
			WHEN 2 THEN 0
			WHEN 3 THEN 0
			WHEN 4 THEN 0
			WHEN 5 THEN 0
			WHEN 6 THEN 1
			WHEN 7 THEN 1
		END,
		[IsHoliday] = 0,
		[DWModifiedDate] = GETDATE()

	-- Update the WeekYear for the week number 1
	UPDATE #Calendar WITH (TABLOCK)
	SET  [WeekYear]=[Year]+1
		,[DWModifiedDate] = GETDATE()
	WHERE [WeekNumber]=1 AND [MonthNumber]=12
	
	-- Update the WeekYear for the week number 52/53
	UPDATE #Calendar WITH (TABLOCK)
	SET  [WeekYear]=[Year]-1
		,[DWModifiedDate] = GETDATE()
	WHERE [WeekNumber]>=52 AND [MonthNumber]=1


	--
	-- Set Holidays
	--
	-- Christmas
	UPDATE #Calendar WITH (TABLOCK)
	SET [IsHoliday] = 1
		,[HolidayName] = 'Christmas'
		,[DWModifiedDate] = GETDATE()
	WHERE ([MonthNumber] = 12 AND [DayNumber] = 24)
		OR ([MonthNumber] = 12 AND [DayNumber] = 25)
		OR ([MonthNumber] = 12 AND [DayNumber] = 26)

	-- New Year
	UPDATE #Calendar WITH (TABLOCK)
	SET [IsHoliday] = 1
		,[HolidayName] = 'New Year'
		,[DWModifiedDate] = GETDATE()
	WHERE ([MonthNumber] = 12 AND [DayNumber] = 31)
		OR ([MonthNumber] = 1 AND [DayNumber] = 1)

	-- Easter
	UPDATE #Calendar WITH (TABLOCK)
	SET [IsHoliday] = 1
		,[HolidayName] = e.EasterDayUKName  --e.EasterDayDKName
		,[DWModifiedDate] = GETDATE()
	FROM
		#Calendar c
	INNER JOIN (
			SELECT
				e.CalendarDate
				,e.EasterDayUKName
				,e.EasterDayDKName
			FROM (
				SELECT DISTINCT [Year]
				FROM #Calendar
				) c
				CROSS APPLY meta.GetEasterDaysFromYear(c.[Year]) e
		) e
			ON c.CalendarDate=e.CalendarDate

	-- Set SpecialDays
	UPDATE #Calendar WITH (TABLOCK)
	SET  SpecialDays = 'Valentines Day'
		,[DWModifiedDate] = GETDATE()
	WHERE ([MonthNumber] = 2 AND [DayNumber] = 14)

	-- Set CalendarIsFutureFlag
	UPDATE #Calendar WITH (TABLOCK)
	SET  [CalendarIsFutureFlag] = IIF([CalendarKey] <= CAST(GETDATE() AS DATE),0,1)
		,[DWModifiedDate] = GETDATE()


	DELETE Calendar WITH (TABLOCK) FROM dim.Calendar WHERE EXISTS (SELECT 1 FROM #Calendar WHERE #Calendar.CalendarID = Calendar.CalendarID)

	INSERT INTO dim.Calendar WITH (TABLOCK)
	([CalendarID]
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
	  ,[DWModifiedDate])

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
	  ,[DWModifiedDate]
	FROM 
		#Calendar

	-- Set IsToday in dimension
	UPDATE dim.Calendar WITH (TABLOCK)
		SET [IsToday] = 0
		,[DWModifiedDate] = GETDATE()
	WHERE [IsToday] = 1

	-- Set IsToday
	UPDATE dim.Calendar WITH (TABLOCK)
		SET [IsToday] = 1
		,[DWModifiedDate] = GETDATE()
	WHERE [CalendarDate] = CAST(GETDATE() AS DATE);


		--CurrentYear, CurrentMonth, CurrentWeek
		
	UPDATE dim.Calendar WITH (TABLOCK)
		SET [CurrentYear] = DATEDIFF(yy,GETDATE(),[CalendarDate]),
		[CurrentQuarter] = DATEDIFF(q,GETDATE(),[CalendarDate]),
		[CurrentMonth] = DATEDIFF(m,GETDATE(),[CalendarDate]),
		[CurrentWeek] = DATEDIFF(ww,GETDATE(),DATEADD(day,-1,[CalendarDate])),
		[CurrentDay] = DATEDIFF(dd,GETDATE(),[CalendarDate]),
		[DWModifiedDate] = GETDATE()


	-- Create View
	IF OBJECT_ID('dimView.Calendar') IS NULL 
	
	BEGIN		

	EXEC('CREATE VIEW dimView.Calendar AS
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
	FROM dim.Calendar')
	END
END
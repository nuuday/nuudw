
CREATE procedure [meta].[CreateTimeDimension] as 

	-- Drop the table if it already exists
IF OBJECT_ID('dim.Time', 'U') IS NOT NULL
BEGIN
    DROP TABLE dim.Time;
END
 
-- Then create a new table
CREATE TABLE dim.[Time](
    [TimeID] [int] IDENTITY(1,1) NOT NULL,
    [TimeHourKey] [int] NULL,
    [TimeMinuteKey] [int] NULL,
    [Time] [time](0) NULL,
    [TimeDayPart] [nvarchar](10) NULL,
    [TimeHourFromTo] [nvarchar](13) NULL,
    [TimeNotation] [nvarchar](10) NULL
);
 
-- Needed if the dimension already existed
-- with other column, otherwise the validation
-- of the insert could fail.
 
-- Create a time and a counter variable for the loop
DECLARE @Time as time;
SET @Time = '0:00';
 
DECLARE @counter as int;
SET @counter = 0;
 
 
-- Two variables to store the day part for two languages
DECLARE @daypartEN as varchar(20);
set @daypartEN = '';
  
-- Loop 1440 times (24hours * 60minutes)
WHILE @counter < 1440
BEGIN
 
    -- Determine datepart
    SELECT  @daypartEN = CASE
                         WHEN (@Time >= '0:00' and @Time < '6:00') THEN 'Night'
                         WHEN (@Time >= '6:00' and @Time < '12:00') THEN 'Morning'
                         WHEN (@Time >= '12:00' and @Time < '18:00') THEN 'Afternoon'
                         ELSE 'Evening'
                         END;
 
    INSERT INTO dim.Time (                    
						 [TimeHourKey]
						,[TimeMinuteKey]
						,[Time]
						,[TimeDayPart]
						,[TimeHourFromTo]
						,[TimeNotation]
						)
                VALUES (
                         DATEPART(Hour, @Time) + 1
                       , DATEPART(Minute, @Time) + 1
					   , @Time
                       , @daypartEN
                       , CAST(DATEADD(Minute, -DATEPART(Minute,@Time), @Time) as varchar(5)) + ' - ' + CAST(DATEADD(Hour, 1, DATEADD(Minute, -DATEPART(Minute,@Time), @Time)) as varchar(5))
                       , CAST(@Time as varchar(5))
                       );
 
    -- Raise time with one minute
    SET @Time = DATEADD(minute, 1, @Time);
 
    -- Raise counter by one
    set @counter = @counter + 1;
END

EXEC('Create View dimView.Time AS
					SELECT * FROM dim.Time')
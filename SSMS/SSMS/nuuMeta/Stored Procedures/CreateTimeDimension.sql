
CREATE PROCEDURE [nuuMeta].[CreateTimeDimension] as 

-- Drop the table if it already exists
IF OBJECT_ID('dim.Time', 'U') IS NOT NULL
BEGIN
    DROP TABLE dim.Time;
    DROP VIEW dimView.Time;
END
 
-- Then create a new table
CREATE TABLE dim.[Time](
    [TimeID] [int] IDENTITY(1,1) NOT NULL,
    [TimeKey] [time](0) NULL
);
 
-- Needed if the dimension already existed
-- with other column, otherwise the validation
-- of the insert could fail.
 
-- Create a time and a counter variable for the loop
DECLARE @Time as time;
SET @Time = '0:00';
 
DECLARE @counter as int;
SET @counter = 0;
 
  
-- Loop 1440 times (24hours * 60minutes)
WHILE @counter < 1440 * 60
BEGIN
 
	INSERT INTO dim.Time ([TimeKey]) VALUES (@Time)

	-- Raise time with one minute
	SET @Time = DATEADD( SECOND, 1, @Time );

	-- Raise counter by one
	SET @counter = @counter + 1;

END


EXEC('CREATE VIEW dimView.Time 
AS
SELECT 
	[TimeID]
	,[TimeKey]
FROM dim.Time')
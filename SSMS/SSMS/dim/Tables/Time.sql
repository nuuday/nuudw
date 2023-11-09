CREATE TABLE [dim].[Time] (
    [TimeID]         INT           IDENTITY (1, 1) NOT NULL,
    [TimeKey]        TIME (0)      NULL,
    [TimeDayPart]    NVARCHAR (10) NULL,
    [TimeHourFromTo] NVARCHAR (13) NULL,
    [TimeNotation]   NVARCHAR (10) NULL
);






CREATE TABLE [dim].[Time] (
    [TimeID]         INT           IDENTITY (1, 1) NOT NULL,
    [TimeHourKey]    INT           NULL,
    [TimeMinuteKey]  INT           NULL,
    [Time]           TIME (0)      NULL,
    [TimeDayPart]    NVARCHAR (10) NULL,
    [TimeHourFromTo] NVARCHAR (13) NULL,
    [TimeNotation]   NVARCHAR (10) NULL
);


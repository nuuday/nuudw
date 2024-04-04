CREATE TABLE [dim].[Time] (
    [TimeID]       INT          IDENTITY (1, 1) NOT NULL,
    [TimeKey]      TIME (0)     NULL,
    [TimeNotation] NVARCHAR (8) NULL,
    [TimeHour]     NVARCHAR (2) NULL,
    [TimeMinute]   NVARCHAR (2) NULL
);








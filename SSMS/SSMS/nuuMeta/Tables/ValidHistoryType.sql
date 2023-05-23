CREATE TABLE [nuuMeta].[ValidHistoryType] (
    [ID]          INT            IDENTITY (1, 1) NOT NULL,
    [HistoryType] NVARCHAR (30)  NOT NULL,
    [Description] NVARCHAR (MAX) NULL,
    CONSTRAINT [AK_HistoryType] UNIQUE NONCLUSTERED ([HistoryType] ASC)
);


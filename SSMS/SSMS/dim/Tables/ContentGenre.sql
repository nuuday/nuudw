CREATE TABLE [dim].[ContentGenre] (
    [ContentGenreID]  INT             IDENTITY (1, 1) NOT NULL,
    [ContentGenreKey] NVARCHAR (1024) NULL,
    [DWIsCurrent]     BIT             NOT NULL,
    [DWValidFromDate] DATETIME2 (0)   NOT NULL,
    [DWValidToDate]   DATETIME2 (0)   NOT NULL,
    [DWCreatedDate]   DATETIME2 (0)   NOT NULL,
    [DWModifiedDate]  DATETIME2 (0)   NOT NULL,
    [DWIsDeleted]     BIT             NOT NULL,
    PRIMARY KEY CLUSTERED ([ContentGenreID] ASC),
    CONSTRAINT [NCI_ContentGenre] UNIQUE NONCLUSTERED ([ContentGenreKey] ASC, [DWValidFromDate] ASC)
);


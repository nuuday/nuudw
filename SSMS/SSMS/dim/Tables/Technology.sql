CREATE TABLE [dim].[Technology] (
    [TechnologyID]    INT           IDENTITY (1, 1) NOT NULL,
    [TechnologyKey]   NVARCHAR (50) NULL,
    [DWIsCurrent]     BIT           NOT NULL,
    [DWValidFromDate] DATETIME2 (0) NOT NULL,
    [DWValidToDate]   DATETIME2 (0) NOT NULL,
    [DWCreatedDate]   DATETIME2 (0) NOT NULL,
    [DWModifiedDate]  DATETIME2 (0) NOT NULL,
    [DWIsDeleted]     BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([TechnologyID] ASC),
    CONSTRAINT [NCI_Technology] UNIQUE NONCLUSTERED ([TechnologyKey] ASC, [DWValidFromDate] ASC)
);


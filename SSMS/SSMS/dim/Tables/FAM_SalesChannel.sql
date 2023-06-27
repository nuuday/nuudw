CREATE TABLE [dim].[FAM_SalesChannel] (
    [FAM_SalesChannelID]  INT           IDENTITY (1, 1) NOT NULL,
    [FAM_SalesChannelKey] VARCHAR (7)   NULL,
    [SalesChannelName]    VARCHAR (11)  NULL,
    [DWIsCurrent]         BIT           NOT NULL,
    [DWValidFromDate]     DATETIME2 (0) NOT NULL,
    [DWValidToDate]       DATETIME2 (0) NOT NULL,
    [DWCreatedDate]       DATETIME2 (0) NOT NULL,
    [DWModifiedDate]      DATETIME2 (0) NOT NULL,
    [DWIsDeleted]         BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([FAM_SalesChannelID] ASC),
    CONSTRAINT [NCI_FAM_SalesChannel] UNIQUE NONCLUSTERED ([FAM_SalesChannelKey] ASC, [DWValidFromDate] ASC)
);


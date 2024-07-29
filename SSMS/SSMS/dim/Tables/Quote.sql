CREATE TABLE [dim].[Quote] (
    [QuoteID]         INT           IDENTITY (1, 1) NOT NULL,
    [QuoteKey]        NVARCHAR (36) NULL,
    [QuoteNumber]     NVARCHAR (10) NULL,
    [DWIsCurrent]     BIT           NOT NULL,
    [DWValidFromDate] DATETIME2 (0) NOT NULL,
    [DWValidToDate]   DATETIME2 (0) NOT NULL,
    [DWCreatedDate]   DATETIME2 (0) NOT NULL,
    [DWModifiedDate]  DATETIME2 (0) NOT NULL,
    [DWIsDeleted]     BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([QuoteID] ASC),
    CONSTRAINT [NCI_Quote] UNIQUE NONCLUSTERED ([QuoteKey] ASC, [DWValidFromDate] ASC)
);




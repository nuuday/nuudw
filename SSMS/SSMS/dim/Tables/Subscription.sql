CREATE TABLE [dim].[Subscription] (
    [SubscriptionID]  INT           IDENTITY (1, 1) NOT NULL,
    [SubscriptionKey] NVARCHAR (36) NULL,
    [DWIsCurrent]     BIT           NOT NULL,
    [DWValidFromDate] DATETIME2 (0) NOT NULL,
    [DWValidToDate]   DATETIME2 (0) NOT NULL,
    [DWCreatedDate]   DATETIME2 (0) NOT NULL,
    [DWModifiedDate]  DATETIME2 (0) NOT NULL,
    [DWIsDeleted]     BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([SubscriptionID] ASC),
    CONSTRAINT [NCI_Subscription] UNIQUE NONCLUSTERED ([SubscriptionKey] ASC, [DWValidFromDate] ASC)
);


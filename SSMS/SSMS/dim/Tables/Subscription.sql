CREATE TABLE [dim].[Subscription] (
    [SubscriptionID]            INT            IDENTITY (1, 1) NOT NULL,
    [SubscriptionKey]           NVARCHAR (36)  NULL,
    [SubscriptionOriginalKey]   NVARCHAR (36)  NULL,
    [FamilyBundle]              NVARCHAR (100) NULL,
    [BundleType]                NVARCHAR (100) NULL,
    [SubscriptionValidFromDate] DATETIME2 (7)  NULL,
    [SubscriptionValidToDate]   DATETIME2 (7)  NULL,
    [SubscriptionIsCurrent]     BIT            NULL,
    [DWIsCurrent]               BIT            NOT NULL,
    [DWValidFromDate]           DATETIME2 (0)  NOT NULL,
    [DWValidToDate]             DATETIME2 (0)  NOT NULL,
    [DWCreatedDate]             DATETIME2 (0)  NOT NULL,
    [DWModifiedDate]            DATETIME2 (0)  NOT NULL,
    [DWIsDeleted]               BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([SubscriptionID] ASC),
    CONSTRAINT [NCI_Subscription] UNIQUE NONCLUSTERED ([SubscriptionKey] ASC, [SubscriptionOriginalKey] ASC, [SubscriptionValidFromDate] ASC)
);








GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Subscription', @level2type = N'COLUMN', @level2name = N'SubscriptionValidToDate';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Subscription', @level2type = N'COLUMN', @level2name = N'SubscriptionValidFromDate';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Subscription', @level2type = N'COLUMN', @level2name = N'SubscriptionKey';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Subscription', @level2type = N'COLUMN', @level2name = N'SubscriptionIsCurrent';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Subscription', @level2type = N'COLUMN', @level2name = N'FamilyBundle';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Subscription', @level2type = N'COLUMN', @level2name = N'BundleType';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Subscription', @level2type = N'COLUMN', @level2name = N'SubscriptionOriginalKey';


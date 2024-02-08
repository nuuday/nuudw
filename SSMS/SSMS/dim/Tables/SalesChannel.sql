CREATE TABLE [dim].[SalesChannel] (
    [SalesChannelID]       INT            IDENTITY (1, 1) NOT NULL,
    [SalesChannelKey]      NVARCHAR (36)  NULL,
    [SalesChannelName]     NVARCHAR (50)  NULL,
    [SalesChannelLongName] NVARCHAR (50)  NULL,
    [SalesChannelType]     NVARCHAR (50)  NULL,
    [InsurancePolicy]      NVARCHAR (50)  NULL,
    [StoreAddress]         NVARCHAR (250) NULL,
    [StoreNumber]          NVARCHAR (20)  NULL,
    [StoreName]            NVARCHAR (50)  NULL,
    [DWIsCurrent]          BIT            NOT NULL,
    [DWValidFromDate]      DATETIME2 (0)  NOT NULL,
    [DWValidToDate]        DATETIME2 (0)  NOT NULL,
    [DWCreatedDate]        DATETIME2 (0)  NOT NULL,
    [DWModifiedDate]       DATETIME2 (0)  NOT NULL,
    [DWIsDeleted]          BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([SalesChannelID] ASC),
    CONSTRAINT [NCI_SalesChannel] UNIQUE NONCLUSTERED ([SalesChannelKey] ASC, [DWValidFromDate] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'SalesChannel', @level2type = N'COLUMN', @level2name = N'StoreName';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'SalesChannel', @level2type = N'COLUMN', @level2name = N'StoreNumber';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'SalesChannel', @level2type = N'COLUMN', @level2name = N'StoreAddress';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'SalesChannel', @level2type = N'COLUMN', @level2name = N'InsurancePolicy';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'SalesChannel', @level2type = N'COLUMN', @level2name = N'SalesChannelType';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'SalesChannel', @level2type = N'COLUMN', @level2name = N'SalesChannelLongName';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'SalesChannel', @level2type = N'COLUMN', @level2name = N'SalesChannelName';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'SalesChannel', @level2type = N'COLUMN', @level2name = N'SalesChannelKey';


CREATE TABLE [dim].[PhoneDetail] (
    [PhoneDetailID]            INT            IDENTITY (1, 1) NOT NULL,
    [PhoneDetailkey]           NVARCHAR (20)  NULL,
    [PhoneStatus]              NVARCHAR (50)  NULL,
    [PhoneCategory]            NVARCHAR (50)  NULL,
    [PortedIn]                 NVARCHAR (1)   NULL,
    [PortedOut]                NVARCHAR (20)  NULL,
    [PortedInFrom]             NVARCHAR (100) NULL,
    [PortedOutTo]              NVARCHAR (100) NULL,
    [PhoneDetailValidFromDate] DATETIME2 (7)  NULL,
    [PhoneDetailValidToDate]   DATETIME2 (7)  NULL,
    [PhoneDetailIsCurrent]     BIT            NULL,
    [DWIsCurrent]              BIT            NOT NULL,
    [DWValidFromDate]          DATETIME2 (0)  NOT NULL,
    [DWValidToDate]            DATETIME2 (0)  NOT NULL,
    [DWCreatedDate]            DATETIME2 (0)  NOT NULL,
    [DWModifiedDate]           DATETIME2 (0)  NOT NULL,
    [DWIsDeleted]              BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([PhoneDetailID] ASC),
    CONSTRAINT [NCI_PhoneDetail] UNIQUE NONCLUSTERED ([PhoneDetailkey] ASC, [PhoneDetailValidFromDate] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'PhoneDetail', @level2type = N'COLUMN', @level2name = N'PortedOut';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'PhoneDetail', @level2type = N'COLUMN', @level2name = N'PortedIn';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'PhoneDetail', @level2type = N'COLUMN', @level2name = N'PhoneStatus';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'PhoneDetail', @level2type = N'COLUMN', @level2name = N'PhoneDetailkey';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'PhoneDetail', @level2type = N'COLUMN', @level2name = N'PhoneCategory';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'PhoneDetail', @level2type = N'COLUMN', @level2name = N'PortedOutTo';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'PhoneDetail', @level2type = N'COLUMN', @level2name = N'PortedInFrom';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'PhoneDetail', @level2type = N'COLUMN', @level2name = N'PhoneDetailValidToDate';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'PhoneDetail', @level2type = N'COLUMN', @level2name = N'PhoneDetailValidFromDate';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'PhoneDetail', @level2type = N'COLUMN', @level2name = N'PhoneDetailIsCurrent';


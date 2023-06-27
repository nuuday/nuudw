CREATE TABLE [dim].[Legacy_Product] (
    [Legacy_ProductID]            INT            IDENTITY (1, 1) NOT NULL,
    [Legacy_ProductKey]           NVARCHAR (20)  NULL,
    [ProductName]                 NVARCHAR (200) NULL,
    [ProductTypeName]             NVARCHAR (50)  NULL,
    [ProductTypeUpdated]          NVARCHAR (50)  NULL,
    [ProductMainCategoryName]     NVARCHAR (50)  NULL,
    [ProductCategoryName]         NVARCHAR (50)  NULL,
    [ProductSubCategoryName]      NVARCHAR (50)  NULL,
    [ProductSubCategorySplitName] NVARCHAR (50)  NULL,
    [ProductWeight]               INT            NULL,
    [ProductBrandCategoryName]    NVARCHAR (50)  NULL,
    [ProductTechnologyName]       NVARCHAR (15)  NULL,
    [ProductGroupCode]            NVARCHAR (10)  NULL,
    [ProductGroupName]            NVARCHAR (100) NULL,
    [Legacy_ProductIsCurrent]     BIT            NULL,
    [Legacy_ProductValidFromDate] DATETIME2 (7)  NULL,
    [Legacy_ProductValidToDate]   DATETIME2 (7)  NULL,
    [DWIsCurrent]                 BIT            NOT NULL,
    [DWValidFromDate]             DATETIME2 (0)  NOT NULL,
    [DWValidToDate]               DATETIME2 (0)  NOT NULL,
    [DWCreatedDate]               DATETIME2 (0)  NOT NULL,
    [DWModifiedDate]              DATETIME2 (0)  NOT NULL,
    [DWIsDeleted]                 BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([Legacy_ProductID] ASC),
    CONSTRAINT [NCI_Legacy_Product] UNIQUE NONCLUSTERED ([Legacy_ProductKey] ASC, [Legacy_ProductValidFromDate] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Legacy_Product', @level2type = N'COLUMN', @level2name = N'Legacy_ProductValidToDate';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Legacy_Product', @level2type = N'COLUMN', @level2name = N'Legacy_ProductValidFromDate';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Legacy_Product', @level2type = N'COLUMN', @level2name = N'Legacy_ProductIsCurrent';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Legacy_Product', @level2type = N'COLUMN', @level2name = N'ProductGroupName';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Legacy_Product', @level2type = N'COLUMN', @level2name = N'ProductGroupCode';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Legacy_Product', @level2type = N'COLUMN', @level2name = N'ProductTechnologyName';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Legacy_Product', @level2type = N'COLUMN', @level2name = N'ProductBrandCategoryName';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Legacy_Product', @level2type = N'COLUMN', @level2name = N'ProductWeight';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Legacy_Product', @level2type = N'COLUMN', @level2name = N'ProductSubCategorySplitName';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Legacy_Product', @level2type = N'COLUMN', @level2name = N'ProductSubCategoryName';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Legacy_Product', @level2type = N'COLUMN', @level2name = N'ProductCategoryName';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Legacy_Product', @level2type = N'COLUMN', @level2name = N'ProductMainCategoryName';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Legacy_Product', @level2type = N'COLUMN', @level2name = N'ProductTypeUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Legacy_Product', @level2type = N'COLUMN', @level2name = N'ProductTypeName';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Legacy_Product', @level2type = N'COLUMN', @level2name = N'ProductName';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Legacy_Product', @level2type = N'COLUMN', @level2name = N'Legacy_ProductKey';


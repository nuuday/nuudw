CREATE TABLE [stage].[Dim_Legacy_Product] (
    [Legacy_ProductKey]           NVARCHAR (20)  NOT NULL,
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
    [Legacy_ProductValidFromDate] DATETIME2 (7)  NOT NULL,
    [Legacy_ProductValidToDate]   DATETIME2 (7)  NULL,
    [DWCreatedDate]               DATETIME       NOT NULL
);


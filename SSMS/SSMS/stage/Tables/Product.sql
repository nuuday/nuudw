CREATE TABLE [stage].[Product] (
    [ProductKey]       NVARCHAR (500) NULL,
    [ProductNo]        NVARCHAR (500) NULL,
    [ProductName]      NVARCHAR (500) NULL,
    [MainProduct]      NVARCHAR (500) NULL,
    [ProductType]      NVARCHAR (500) NULL,
    [AddonProduct]     NVARCHAR (500) NULL,
    [ProductIsCurrent] BIT            NULL,
    [DWCreatedDate]    DATETIME       NOT NULL
);


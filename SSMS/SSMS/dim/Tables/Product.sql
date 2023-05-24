CREATE TABLE [dim].[Product] (
    [ProductID]        INT            IDENTITY (1, 1) NOT NULL,
    [ProductKey]       NVARCHAR (500) NULL,
    [ProductNo]        NVARCHAR (500) NULL,
    [ProductName]      NVARCHAR (500) NULL,
    [MainProduct]      NVARCHAR (500) NULL,
    [ProductType]      NVARCHAR (500) NULL,
    [AddonProduct]     NVARCHAR (500) NULL,
    [ProductIsCurrent] BIT            NULL,
    [DWIsCurrent]      BIT            NOT NULL,
    [DWValidFromDate]  DATETIME       NOT NULL,
    [DWValidToDate]    DATETIME       NOT NULL,
    [DWCreatedDate]    DATETIME       NOT NULL,
    [DWModifiedDate]   DATETIME       NOT NULL,
    [DWIsDeleted]      BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([ProductID] ASC),
    CONSTRAINT [NCI_Product] UNIQUE NONCLUSTERED ([ProductKey] ASC, [DWValidFromDate] ASC)
);


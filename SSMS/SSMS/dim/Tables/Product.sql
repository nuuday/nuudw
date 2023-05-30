CREATE TABLE [dim].[Product] (
    [ProductID]       INT            IDENTITY (1, 1) NOT NULL,
    [ProductKey]      NVARCHAR (50)  NULL,
    [ProductName]     NVARCHAR (250) NULL,
    [ProductType]     NVARCHAR (50)  NULL,
    [DWIsCurrent]     BIT            NOT NULL,
    [DWValidFromDate] DATETIME       NOT NULL,
    [DWValidToDate]   DATETIME       NOT NULL,
    [DWCreatedDate]   DATETIME       NOT NULL,
    [DWModifiedDate]  DATETIME       NOT NULL,
    [DWIsDeleted]     BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([ProductID] ASC),
    CONSTRAINT [NCI_Product] UNIQUE NONCLUSTERED ([ProductKey] ASC, [DWValidFromDate] ASC)
);






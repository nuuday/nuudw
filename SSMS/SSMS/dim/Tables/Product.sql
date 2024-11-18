CREATE TABLE [dim].[Product] (
    [ProductID]       INT            IDENTITY (1, 1) NOT NULL,
    [ProductKey]      NVARCHAR (36)  NULL,
    [ProductName]     NVARCHAR (250) NULL,
    [ProductType]     NVARCHAR (50)  NULL,
    [ProductWeight]   NVARCHAR (30)  NULL,
    [DWIsCurrent]     BIT            NOT NULL,
    [DWValidFromDate] DATETIME2 (0)  NOT NULL,
    [DWValidToDate]   DATETIME2 (0)  NOT NULL,
    [DWCreatedDate]   DATETIME2 (0)  NOT NULL,
    [DWModifiedDate]  DATETIME2 (0)  NOT NULL,
    [DWIsDeleted]     BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([ProductID] ASC),
    CONSTRAINT [NCI_Product] UNIQUE NONCLUSTERED ([ProductKey] ASC, [DWValidFromDate] ASC)
);














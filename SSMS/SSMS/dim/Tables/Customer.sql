CREATE TABLE [dim].[Customer] (
    [CustomerID]      INT            IDENTITY (1, 1) NOT NULL,
    [CustomerKey]     NVARCHAR (50)  NULL,
    [CustomerNo]      NVARCHAR (50)  NULL,
    [CustomerName]    NVARCHAR (250) NULL,
    [CustomerSegment] NVARCHAR (50)  NULL,
    [CustomerStatus]  NVARCHAR (20)  NULL,
    [DWIsCurrent]     BIT            NOT NULL,
    [DWValidFromDate] DATETIME       NOT NULL,
    [DWValidToDate]   DATETIME       NOT NULL,
    [DWCreatedDate]   DATETIME       NOT NULL,
    [DWModifiedDate]  DATETIME       NOT NULL,
    [DWIsDeleted]     BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([CustomerID] ASC),
    CONSTRAINT [NCI_Customer] UNIQUE NONCLUSTERED ([CustomerKey] ASC, [DWValidFromDate] ASC)
);




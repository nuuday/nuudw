CREATE TABLE [dim].[Customer] (
    [CustomerID]        INT            IDENTITY (1, 1) NOT NULL,
    [CustomerKey]       NVARCHAR (500) NULL,
    [CustomerNo]        NVARCHAR (500) NULL,
    [CustomerName]      NVARCHAR (500) NULL,
    [CustomerSegment]   NVARCHAR (500) NULL,
    [CustomerStatus]    NVARCHAR (500) NULL,
    [CustomerIsCurrent] INT            NULL,
    [DWIsCurrent]       BIT            NOT NULL,
    [DWValidFromDate]   DATETIME       NOT NULL,
    [DWValidToDate]     DATETIME       NOT NULL,
    [DWCreatedDate]     DATETIME       NOT NULL,
    [DWModifiedDate]    DATETIME       NOT NULL,
    [DWIsDeleted]       BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([CustomerID] ASC),
    CONSTRAINT [NCI_Customer] UNIQUE NONCLUSTERED ([CustomerKey] ASC, [DWValidFromDate] ASC)
);


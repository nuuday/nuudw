CREATE TABLE [dim].[Customer] (
    [CustomerID]              INT            IDENTITY (1, 1) NOT NULL,
    [CustomerKey]             NVARCHAR (36)  NULL,
    [CustomerNumber]          NVARCHAR (12)  NULL,
    [CustomerName]            NVARCHAR (250) NULL,
    [CustomerSegment]         NVARCHAR (50)  NULL,
    [CustomerStatus]          NVARCHAR (20)  NULL,
    [CustomerMigrationSource] NVARCHAR (100) NULL,
    [CustomerMigrationDate]   DATETIME2 (7)  NULL,
    [DWIsCurrent]             BIT            NOT NULL,
    [DWValidFromDate]         DATETIME2 (0)  NOT NULL,
    [DWValidToDate]           DATETIME2 (0)  NOT NULL,
    [DWCreatedDate]           DATETIME2 (0)  NOT NULL,
    [DWModifiedDate]          DATETIME2 (0)  NOT NULL,
    [DWIsDeleted]             BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([CustomerID] ASC),
    CONSTRAINT [NCI_Customer] UNIQUE NONCLUSTERED ([CustomerKey] ASC, [DWValidFromDate] ASC)
);










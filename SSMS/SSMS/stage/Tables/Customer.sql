CREATE TABLE [stage].[Customer] (
    [CustomerKey]       NVARCHAR (500) NULL,
    [CustomerNo]        NVARCHAR (500) NULL,
    [CustomerName]      NVARCHAR (500) NULL,
    [CustomerSegment]   NVARCHAR (500) NULL,
    [CustomerStatus]    NVARCHAR (500) NULL,
    [CustomerIsCurrent] INT            NOT NULL,
    [DWCreatedDate]     DATETIME       NOT NULL
);


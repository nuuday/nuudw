CREATE TABLE [stage].[Dim_Customer] (
    [CustomerKey]     NVARCHAR (50)  NULL,
    [CustomerNo]      NVARCHAR (50)  NULL,
    [CustomerName]    NVARCHAR (250) NULL,
    [CustomerSegment] NVARCHAR (50)  NULL,
    [CustomerStatus]  NVARCHAR (20)  NULL,
    [DWCreatedDate]   DATETIME       NOT NULL
);


CREATE TABLE [stage].[Dim_Customer] (
    [CustomerKey]     NVARCHAR (12)  NULL,
    [CustomerName]    NVARCHAR (250) NULL,
    [CustomerSegment] NVARCHAR (50)  NULL,
    [CustomerStatus]  NVARCHAR (20)  NULL,
    [DWCreatedDate]   DATETIME2 (0)  DEFAULT (sysdatetime()) NOT NULL
);






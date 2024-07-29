CREATE TABLE [stage].[Dim_Customer] (
    [CustomerKey]             NVARCHAR (36)  NULL,
    [CustomerNumber]          NVARCHAR (12)  NULL,
    [CustomerName]            NVARCHAR (250) NULL,
    [CustomerSegment]         NVARCHAR (50)  NULL,
    [CustomerStatus]          NVARCHAR (20)  NULL,
    [CustomerMigrationSource] NVARCHAR (100) NULL,
    [CustomerMigrationDate]   DATETIME2 (0)  NULL,
    [DWCreatedDate]           DATETIME2 (0)  DEFAULT (sysdatetime()) NULL
);








CREATE TABLE [stage].[Dim_SalesChannel] (
    [SalesChannelKey]      NVARCHAR (36)  NULL,
    [SalesChannelName]     NVARCHAR (50)  NULL,
    [SalesChannelLongName] NVARCHAR (50)  NULL,
    [SalesChannelType]     NVARCHAR (50)  NULL,
    [InsurancePolicy]      NVARCHAR (50)  NULL,
    [StoreAddress]         NVARCHAR (250) NULL,
    [StoreNumber]          NVARCHAR (20)  NULL,
    [StoreName]            NVARCHAR (50)  NULL,
    [DWCreatedDate]        DATETIME2 (0)  DEFAULT (sysdatetime()) NOT NULL
);




CREATE TABLE [stage].[Dim_ThirdPartyStore] (
    [ThirdPartyStoreKey] INT            NOT NULL,
    [StoreID]            INT            NULL,
    [StoreName]          NVARCHAR (100) NULL,
    [DWCreatedDate]      DATETIME2 (0)  DEFAULT (sysdatetime()) NULL
);


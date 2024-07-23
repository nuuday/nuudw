CREATE TABLE [masterdata].[ThirdPartyStores_History] (
    [ID]            INT            NOT NULL,
    [StoreID]       INT            NULL,
    [YouSeeStoreID] INT            NULL,
    [StoreName]     NVARCHAR (100) NULL,
    [ValidFrom]     DATETIME2 (7)  NOT NULL,
    [ValidTo]       DATETIME2 (7)  NOT NULL
);


GO
CREATE CLUSTERED INDEX [ix_Elgiganten_Stores_History]
    ON [masterdata].[ThirdPartyStores_History]([ValidTo] ASC, [ValidFrom] ASC) WITH (DATA_COMPRESSION = PAGE);


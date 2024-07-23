CREATE TABLE [masterdata].[ThirdPartyStores] (
    [ID]            INT                                                IDENTITY (1, 1) NOT NULL,
    [StoreID]       INT                                                NULL,
    [YouSeeStoreID] INT                                                NULL,
    [StoreName]     NVARCHAR (100)                                     NULL,
    [ValidFrom]     DATETIME2 (7) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_Elgiganten_Stores_ValidFrom] DEFAULT (sysutcdatetime()) NOT NULL,
    [ValidTo]       DATETIME2 (7) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_Elgiganten_Stores_ValidTo] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999')) NOT NULL,
    CONSTRAINT [PK_Elgiganten_Stores] PRIMARY KEY CLUSTERED ([ID] ASC),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[masterdata].[ThirdPartyStores_History], DATA_CONSISTENCY_CHECK=ON));


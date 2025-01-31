CREATE TABLE [masterdata].[ProductTypeMapping] (
    [ID]              INT                                                IDENTITY (1, 1) NOT NULL,
    [Producttype_org] NVARCHAR (100)                                     NULL,
    [Producttype]     NVARCHAR (100)                                     NULL,
    [ValidFrom]       DATETIME2 (7) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_ProductTypeMapping_ValidFrom] DEFAULT (sysutcdatetime()) NOT NULL,
    [ValidTo]         DATETIME2 (7) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_ProductTypeMapping_ValidTo] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999')) NOT NULL,
    CONSTRAINT [PK_ProductTypeMapping] PRIMARY KEY CLUSTERED ([ID] ASC),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[masterdata].[ProductTypeMapping_History], DATA_CONSISTENCY_CHECK=ON));


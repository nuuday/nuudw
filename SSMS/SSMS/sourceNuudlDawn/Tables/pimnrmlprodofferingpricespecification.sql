CREATE TABLE [sourceNuudlDawn].[pimnrmlprodofferingpricespecification] (
    [external_id]                     NVARCHAR (50)  NULL,
    [id]                              NVARCHAR (50)  NULL,
    [name]                            NVARCHAR (500) NULL,
    [price_type]                      NVARCHAR (500) NULL,
    [extended_parameters]             NVARCHAR (500) NULL,
    [cdc_revision_id]                 NVARCHAR (50)  NULL,
    [localized_name_json_dan]         NVARCHAR (500) NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]                 BIT            NULL,
    [NUUDL_ID]                        BIGINT         NOT NULL,
    [NUUDL_CuratedBatchID]            INT            NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (500) NULL,
    [DWCreatedDate]                   DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_pimnrmlprodofferingpricespecification] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_pimnrmlprodofferingpricespecification]
    ON [sourceNuudlDawn].[pimnrmlprodofferingpricespecification];


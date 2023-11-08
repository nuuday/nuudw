CREATE TABLE [sourceNuudlNetCracker].[pimnrmlprodcatprodoffering] (
    [product_catalog_id]   NVARCHAR (36) NULL,
    [product_offering_id]  NVARCHAR (36) NULL,
    [cdc_revision_id]      NVARCHAR (36) NULL,
    [NUUDL_ValidFrom]      DATETIME2 (7) NULL,
    [NUUDL_ValidTo]        DATETIME2 (7) NULL,
    [NUUDL_IsCurrent]      BIT           NULL,
    [NUUDL_ID]             BIGINT        NOT NULL,
    [NUUDL_CuratedBatchID] BIGINT        NULL,
    [DWCreatedDate]        DATETIME2 (7) DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_pimnrmlprodcatprodoffering] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_pimnrmlprodcatprodoffering]
    ON [sourceNuudlNetCracker].[pimnrmlprodcatprodoffering];


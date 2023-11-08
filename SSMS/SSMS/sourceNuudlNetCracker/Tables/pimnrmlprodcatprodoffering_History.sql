CREATE TABLE [sourceNuudlNetCracker].[pimnrmlprodcatprodoffering_History] (
    [product_catalog_id]    NVARCHAR (36) NULL,
    [product_offering_id]   NVARCHAR (36) NULL,
    [cdc_revision_id]       NVARCHAR (36) NULL,
    [NUUDL_ValidFrom]       DATETIME2 (7) NULL,
    [NUUDL_ValidTo]         DATETIME2 (7) NULL,
    [NUUDL_IsCurrent]       BIT           NULL,
    [NUUDL_ID]              BIGINT        NOT NULL,
    [NUUDL_CuratedBatchID]  BIGINT        NULL,
    [DWIsCurrent]           BIT           NULL,
    [DWValidFromDate]       DATETIME2 (7) NOT NULL,
    [DWValidToDate]         DATETIME2 (7) NULL,
    [DWCreatedDate]         DATETIME2 (7) NULL,
    [DWModifiedDate]        DATETIME2 (7) NULL,
    [DWIsDeletedInSource]   BIT           NULL,
    [DWDeletedInSourceDate] DATETIME2 (7) NULL,
    CONSTRAINT [PK_pimnrmlprodcatprodoffering_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_pimnrmlprodcatprodoffering_History]
    ON [sourceNuudlNetCracker].[pimnrmlprodcatprodoffering_History];


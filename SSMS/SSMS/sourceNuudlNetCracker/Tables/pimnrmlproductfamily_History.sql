CREATE TABLE [sourceNuudlNetCracker].[pimnrmlproductfamily_History] (
    [localized_name_json_dan] NVARCHAR (300) NULL,
    [id]                      NVARCHAR (36)  NULL,
    [name]                    NVARCHAR (300) NULL,
    [external_id]             NVARCHAR (36)  NULL,
    [extended_parameters]     NVARCHAR (300) NULL,
    [cdc_revision_id]         NVARCHAR (36)  NULL,
    [NUUDL_ValidFrom]         DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]           DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]         BIT            NULL,
    [NUUDL_ID]                BIGINT         NOT NULL,
    [NUUDL_CuratedBatchID]    BIGINT         NULL,
    [DWIsCurrent]             BIT            NULL,
    [DWValidFromDate]         DATETIME2 (7)  NOT NULL,
    [DWValidToDate]           DATETIME2 (7)  NULL,
    [DWCreatedDate]           DATETIME2 (7)  NULL,
    [DWModifiedDate]          DATETIME2 (7)  NULL,
    [DWIsDeletedInSource]     BIT            NULL,
    [DWDeletedInSourceDate]   DATETIME2 (7)  NULL,
    CONSTRAINT [PK_pimnrmlproductfamily_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_pimnrmlproductfamily_History]
    ON [sourceNuudlNetCracker].[pimnrmlproductfamily_History];


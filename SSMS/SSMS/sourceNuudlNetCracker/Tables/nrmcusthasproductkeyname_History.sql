CREATE TABLE [sourceNuudlNetCracker].[nrmcusthasproductkeyname_History] (
    [customer_ref]          NVARCHAR (300) NULL,
    [product_seq]           INT            NULL,
    [name]                  NVARCHAR (300) NULL,
    [is_current]            BIT            NULL,
    [NUUDL_ValidFrom]       DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]         DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]       BIT            NULL,
    [NUUDL_ID]              BIGINT         NOT NULL,
    [NUUDL_CuratedBatchID]  BIGINT         NULL,
    [DWIsCurrent]           BIT            NULL,
    [DWValidFromDate]       DATETIME2 (7)  NOT NULL,
    [DWValidToDate]         DATETIME2 (7)  NULL,
    [DWCreatedDate]         DATETIME2 (7)  NULL,
    [DWModifiedDate]        DATETIME2 (7)  NULL,
    [DWIsDeletedInSource]   BIT            NULL,
    [DWDeletedInSourceDate] DATETIME2 (7)  NULL,
    CONSTRAINT [PK_nrmcusthasproductkeyname_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_nrmcusthasproductkeyname_History]
    ON [sourceNuudlNetCracker].[nrmcusthasproductkeyname_History];


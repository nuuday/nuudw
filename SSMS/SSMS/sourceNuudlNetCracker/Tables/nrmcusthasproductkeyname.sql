CREATE TABLE [sourceNuudlNetCracker].[nrmcusthasproductkeyname] (
    [customer_ref]         NVARCHAR (300) NULL,
    [product_seq]          INT            NULL,
    [name]                 NVARCHAR (300) NULL,
    [is_current]           BIT            NULL,
    [NUUDL_ValidFrom]      DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]        DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]      BIT            NULL,
    [NUUDL_ID]             BIGINT         NOT NULL,
    [NUUDL_CuratedBatchID] BIGINT         NULL,
    [DWCreatedDate]        DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_nrmcusthasproductkeyname] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_nrmcusthasproductkeyname]
    ON [sourceNuudlNetCracker].[nrmcusthasproductkeyname];


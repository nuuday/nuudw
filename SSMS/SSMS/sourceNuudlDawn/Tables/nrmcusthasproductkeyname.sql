CREATE TABLE [sourceNuudlDawn].[nrmcusthasproductkeyname] (
    [customer_ref]                    NVARCHAR (4000) NULL,
    [name]                            NVARCHAR (4000) NULL,
    [product_seq]                     BIGINT          NULL,
    [ts_ms]                           BIGINT          NULL,
    [lsn]                             BIGINT          NULL,
    [op]                              NVARCHAR (4000) NULL,
    [NUUDL_IsCurrent]                 BIT             NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)   NULL,
    [NUUDL_CuratedBatchID]            INT             NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (4000) NULL,
    [NUUDL_IsDeleted]                 BIT             NULL,
    [NUUDL_DeleteType]                NVARCHAR (4000) NULL,
    [NUUDL_ID]                        BIGINT          NOT NULL,
    [NUUDL_IsLatest]                  BIT             NULL,
    [DWCreatedDate]                   DATETIME2 (7)   DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_nrmcusthasproductkeyname] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);






GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_nrmcusthasproductkeyname]
    ON [sourceNuudlDawn].[nrmcusthasproductkeyname];






CREATE TABLE [sourceNuudlDawn].[ibsitemshistory] (
    [active_from]                     DATETIME2 (7)  NULL,
    [active_to]                       DATETIME2 (7)  NULL,
    [id]                              NVARCHAR (50)  NULL,
    [idempotency_key]                 NVARCHAR (500) NULL,
    [is_snapshot]                     BIT            NULL,
    [item]                            NVARCHAR (MAX) NULL,
    [last_modified_ts]                DATETIME2 (7)  NULL,
    [op]                              NVARCHAR (500) NULL,
    [schema_version]                  NVARCHAR (500) NULL,
    [state]                           NVARCHAR (500) NULL,
    [ts_ms]                           BIGINT         NULL,
    [version]                         NVARCHAR (500) NULL,
    [NUUDL_CuratedBatchID]            INT            NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (500) NULL,
    [NUUDL_IsCurrent]                 BIT            NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)  NULL,
    [NUUDL_ID]                        BIGINT         NOT NULL,
    [DWCreatedDate]                   DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_ibsitemshistory] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ibsitemshistory]
    ON [sourceNuudlDawn].[ibsitemshistory];


CREATE TABLE [sourceNuudlDawn].[ibsitemshistory_History] (
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
    [DWIsCurrent]                     BIT            NULL,
    [DWValidFromDate]                 DATETIME2 (7)  NOT NULL,
    [DWValidToDate]                   DATETIME2 (7)  NULL,
    [DWCreatedDate]                   DATETIME2 (7)  NULL,
    [DWModifiedDate]                  DATETIME2 (7)  NULL,
    [DWIsDeletedInSource]             BIT            NULL,
    [DWDeletedInSourceDate]           DATETIME2 (7)  NULL,
    CONSTRAINT [PK_ibsitemshistory_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ibsitemshistory_History]
    ON [sourceNuudlDawn].[ibsitemshistory_History];


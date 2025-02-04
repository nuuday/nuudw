CREATE TABLE [sourceNuudlDawn].[ibsrealizingserviceref_History] (
    [id]                              NVARCHAR (50)   NULL,
    [name]                            NVARCHAR (4000) NULL,
    [product_instance_id]             NVARCHAR (50)   NULL,
    [ref_id]                          NVARCHAR (50)   NULL,
    [ref_type]                        NVARCHAR (4000) NULL,
    [role]                            NVARCHAR (4000) NULL,
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
    [NUUDL_IsLatest]                  BIT             NULL,
    [NUUDL_ID]                        BIGINT          NOT NULL,
    [DWIsCurrent]                     BIT             NULL,
    [DWValidFromDate]                 DATETIME2 (7)   NOT NULL,
    [DWValidToDate]                   DATETIME2 (7)   NULL,
    [DWCreatedDate]                   DATETIME2 (7)   NULL,
    [DWModifiedDate]                  DATETIME2 (7)   NULL,
    [DWIsDeletedInSource]             BIT             NULL,
    [DWDeletedInSourceDate]           DATETIME2 (7)   NULL,
    CONSTRAINT [PK_ibsrealizingserviceref_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ibsrealizingserviceref_History]
    ON [sourceNuudlDawn].[ibsrealizingserviceref_History];


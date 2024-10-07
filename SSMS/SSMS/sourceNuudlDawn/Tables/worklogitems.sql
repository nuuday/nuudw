CREATE TABLE [sourceNuudlDawn].[worklogitems] (
    [attributes]                      NVARCHAR (MAX)  NULL,
    [changedby]                       NVARCHAR (MAX)  NULL,
    [date]                            DATETIME2 (7)   NULL,
    [description]                     NVARCHAR (MAX)  NULL,
    [id]                              NVARCHAR (50)   NULL,
    [name]                            NVARCHAR (4000) NULL,
    [ref_id]                          NVARCHAR (50)   NULL,
    [ref_type]                        NVARCHAR (4000) NULL,
    [source]                          NVARCHAR (4000) NULL,
    [source_state]                    NVARCHAR (4000) NULL,
    [target_state]                    NVARCHAR (4000) NULL,
    [ts_ms]                           BIGINT          NULL,
    [lsn]                             BIGINT          NULL,
    [op]                              NVARCHAR (4000) NULL,
    [changedby_userId]                NVARCHAR (4000) NULL,
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
    CONSTRAINT [PK_worklogitems] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);








GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_worklogitems]
    ON [sourceNuudlDawn].[worklogitems];








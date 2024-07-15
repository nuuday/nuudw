CREATE TABLE [sourceNuudlDawn].[worklogitems] (
    [attributes]                      NVARCHAR (MAX) NULL,
    [changedby]                       NVARCHAR (MAX) NULL,
    [date]                            DATETIME2 (7)  NULL,
    [description]                     NVARCHAR (MAX) NULL,
    [id]                              NVARCHAR (50)  NULL,
    [name]                            NVARCHAR (500) NULL,
    [op]                              NVARCHAR (500) NULL,
    [ref_id]                          NVARCHAR (50)  NULL,
    [ref_type]                        NVARCHAR (500) NULL,
    [source]                          NVARCHAR (500) NULL,
    [source_state]                    NVARCHAR (500) NULL,
    [target_state]                    NVARCHAR (500) NULL,
    [ts_ms]                           BIGINT         NULL,
    [NUUDL_CuratedBatchID]            INT            NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (500) NULL,
    [NUUDL_IsCurrent]                 BIT            NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)  NULL,
    [NUUDL_ID]                        BIGINT         NOT NULL,
    [DWCreatedDate]                   DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_worklogitems] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_worklogitems]
    ON [sourceNuudlDawn].[worklogitems];


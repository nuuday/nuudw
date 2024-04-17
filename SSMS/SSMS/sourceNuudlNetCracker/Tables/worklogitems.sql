CREATE TABLE [sourceNuudlNetCracker].[worklogitems] (
    [id]                                   NVARCHAR (36)  NULL,
    [name]                                 NVARCHAR (300) NULL,
    [description]                          NVARCHAR (300) NULL,
    [date]                                 DATETIME2 (7)  NULL,
    [source]                               NVARCHAR (300) NULL,
    [ref_id]                               NVARCHAR (36)  NULL,
    [ref_type]                             NVARCHAR (300) NULL,
    [source_state]                         NVARCHAR (300) NULL,
    [target_state]                         NVARCHAR (300) NULL,
    [attributes]                           NVARCHAR (300) NULL,
    [is_deleted]                           BIT            NULL,
    [last_modified_ts]                     DATETIME2 (7)  NULL,
    [is_current]                           BIT            NULL,
    [changedby_json_m2m]                   NVARCHAR (300) NULL,
    [changedby_json_service]               NVARCHAR (300) NULL,
    [changedby_json_userId]                NVARCHAR (36)  NULL,
    [changedby_json_userName]              NVARCHAR (300) NULL,
    [NUUDL_ValidFrom]                      DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                        DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]                      BIT            NULL,
    [NUUDL_ID]                             BIGINT         NOT NULL,
    [NUUDL_StandardizedProcessedTimestamp] DATETIME2 (7)  NULL,
    [NUUDL_CuratedBatchID]                 INT            NULL,
    [NUUDL_CuratedProcessedTimestamp]      NVARCHAR (300) NULL,
    [NUUDL_CuratedSourceFilename]          NVARCHAR (300) NULL,
    [DWCreatedDate]                        DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_worklogitems] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_worklogitems]
    ON [sourceNuudlNetCracker].[worklogitems];


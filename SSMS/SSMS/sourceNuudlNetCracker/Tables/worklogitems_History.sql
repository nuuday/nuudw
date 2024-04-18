CREATE TABLE [sourceNuudlNetCracker].[worklogitems_History] (
    [id]                                   NVARCHAR (36)  NULL,
    [name]                                 NVARCHAR (300) NULL,
    [description]                          NVARCHAR (300) NULL,
    [date]                                 DATETIME2 (7)  NULL,
    [source]                               NVARCHAR (300) NULL,
    [ref_id]                               NVARCHAR (37)  NULL,
    [ref_type]                             NVARCHAR (300) NULL,
    [source_state]                         NVARCHAR (300) NULL,
    [target_state]                         NVARCHAR (300) NULL,
    [attributes]                           NVARCHAR (300) NULL,
    [is_deleted]                           BIT            NULL,
    [last_modified_ts]                     DATETIME2 (7)  NULL,
    [is_current]                           BIT            NULL,
    [changedby_json_m2m]                   NVARCHAR (300) NULL,
    [changedby_json_service]               NVARCHAR (300) NULL,
    [changedby_json_userId]                NVARCHAR (38)  NULL,
    [changedby_json_userName]              NVARCHAR (300) NULL,
    [NUUDL_ValidFrom]                      DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                        DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]                      BIT            NULL,
    [NUUDL_ID]                             BIGINT         NOT NULL,
    [NUUDL_StandardizedProcessedTimestamp] DATETIME2 (7)  NULL,
    [NUUDL_CuratedBatchID]                 INT            NULL,
    [NUUDL_CuratedProcessedTimestamp]      NVARCHAR (300) NULL,
    [NUUDL_CuratedSourceFilename]          NVARCHAR (300) NULL,
    [DWIsCurrent]                          BIT            NULL,
    [DWValidFromDate]                      DATETIME2 (7)  NOT NULL,
    [DWValidToDate]                        DATETIME2 (7)  NULL,
    [DWCreatedDate]                        DATETIME2 (7)  NULL,
    [DWModifiedDate]                       DATETIME2 (7)  NULL,
    [DWIsDeletedInSource]                  BIT            NULL,
    [DWDeletedInSourceDate]                DATETIME2 (7)  NULL,
    CONSTRAINT [PK_worklogitems_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_worklogitems_History]
    ON [sourceNuudlNetCracker].[worklogitems_History];


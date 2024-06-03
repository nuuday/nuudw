CREATE TABLE [sourceNuudlDawn].[cimcontactmediumassociation_History] (
    [active_from]                     DATETIME2 (7)  NULL,
    [changed_by]                      NVARCHAR (MAX) NULL,
    [contact_medium_id]               NVARCHAR (36)  NULL,
    [id]                              NVARCHAR (36)  NULL,
    [op]                              NVARCHAR (500) NULL,
    [ref_id]                          NVARCHAR (36)  NULL,
    [ref_type]                        NVARCHAR (500) NULL,
    [ts_ms]                           BIGINT         NULL,
    [NUUDL_RescuedData]               NVARCHAR (500) NULL,
    [NUUDL_BaseSourceFilename]        NVARCHAR (500) NULL,
    [NUUDL_BaseBatchID]               INT            NULL,
    [NUUDL_BaseProcessedTimestamp]    NVARCHAR (500) NULL,
    [Snapshot]                        NVARCHAR (500) NULL,
    [Partition_Snapshot]              NVARCHAR (500) NULL,
    [NUUDL_CuratedBatchID]            INT            NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (500) NULL,
    [NUUDL_CuratedSourceFilename]     NVARCHAR (500) NULL,
    [NUUDL_IsCurrent]                 BIT            NULL,
    [NUUDL_ValidFrom]                 NVARCHAR (500) NULL,
    [NUUDL_ValidTo]                   NVARCHAR (500) NULL,
    [NUUDL_ID]                        BIGINT         NOT NULL,
    [DWIsCurrent]                     BIT            NULL,
    [DWValidFromDate]                 DATETIME2 (7)  NOT NULL,
    [DWValidToDate]                   DATETIME2 (7)  NULL,
    [DWCreatedDate]                   DATETIME2 (7)  NULL,
    [DWModifiedDate]                  DATETIME2 (7)  NULL,
    [DWIsDeletedInSource]             BIT            NULL,
    [DWDeletedInSourceDate]           DATETIME2 (7)  NULL,
    CONSTRAINT [PK_cimcontactmediumassociation_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cimcontactmediumassociation_History]
    ON [sourceNuudlDawn].[cimcontactmediumassociation_History];


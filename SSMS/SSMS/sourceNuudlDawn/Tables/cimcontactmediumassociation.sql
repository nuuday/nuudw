CREATE TABLE [sourceNuudlDawn].[cimcontactmediumassociation] (
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
    [DWCreatedDate]                   DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_cimcontactmediumassociation] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cimcontactmediumassociation]
    ON [sourceNuudlDawn].[cimcontactmediumassociation];


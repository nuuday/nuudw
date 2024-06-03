CREATE TABLE [sourceNuudlDawn].[cimpartyrole] (
    [active_from]                     DATETIME2 (7)  NULL,
    [billing_synchronization_status]  NVARCHAR (500) NULL,
    [changed_by]                      NVARCHAR (MAX) NULL,
    [end_date_time]                   NVARCHAR (500) NULL,
    [engaged_party_description]       NVARCHAR (500) NULL,
    [engaged_party_id]                NVARCHAR (36)  NULL,
    [engaged_party_name]              NVARCHAR (500) NULL,
    [engaged_party_ref_type]          NVARCHAR (500) NULL,
    [extended_attributes]             NVARCHAR (MAX) NULL,
    [id]                              NVARCHAR (36)  NULL,
    [idempotency_key]                 NVARCHAR (500) NULL,
    [name]                            NVARCHAR (500) NULL,
    [ola_ref]                         NVARCHAR (MAX) NULL,
    [op]                              NVARCHAR (500) NULL,
    [party_role_type]                 NVARCHAR (500) NULL,
    [start_date_time]                 NVARCHAR (500) NULL,
    [status]                          NVARCHAR (500) NULL,
    [status_reason]                   NVARCHAR (500) NULL,
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
    CONSTRAINT [PK_cimpartyrole] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cimpartyrole]
    ON [sourceNuudlDawn].[cimpartyrole];


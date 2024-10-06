CREATE TABLE [sourceNuudlDawn].[cimpartyrole] (
    [active_from]                     DATETIME2 (7)   NULL,
    [billing_synchronization_status]  NVARCHAR (4000) NULL,
    [changed_by]                      NVARCHAR (MAX)  NULL,
    [end_date_time]                   DATETIME2 (7)   NULL,
    [engaged_party_description]       NVARCHAR (4000) NULL,
    [engaged_party_id]                NVARCHAR (50)   NULL,
    [engaged_party_name]              NVARCHAR (4000) NULL,
    [engaged_party_ref_type]          NVARCHAR (4000) NULL,
    [extended_attributes]             NVARCHAR (MAX)  NULL,
    [id]                              NVARCHAR (50)   NULL,
    [idempotency_key]                 NVARCHAR (4000) NULL,
    [name]                            NVARCHAR (4000) NULL,
    [ola_ref]                         NVARCHAR (MAX)  NULL,
    [party_role_type]                 NVARCHAR (4000) NULL,
    [start_date_time]                 DATETIME2 (7)   NULL,
    [status]                          NVARCHAR (4000) NULL,
    [status_reason]                   NVARCHAR (4000) NULL,
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
    [DWCreatedDate]                   DATETIME2 (7)   DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_cimpartyrole] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);






GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cimpartyrole]
    ON [sourceNuudlDawn].[cimpartyrole];






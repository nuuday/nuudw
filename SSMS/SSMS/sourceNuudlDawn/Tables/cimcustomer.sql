CREATE TABLE [sourceNuudlDawn].[cimcustomer] (
    [active_from]                     DATETIME2 (7)  NULL,
    [billing_data]                    NVARCHAR (MAX) NULL,
    [billing_synchronization_status]  NVARCHAR (500) NULL,
    [brand_id]                        NVARCHAR (50)  NULL,
    [changed_by]                      NVARCHAR (MAX) NULL,
    [customer_category_id]            NVARCHAR (50)  NULL,
    [customer_number]                 NVARCHAR (500) NULL,
    [customer_since]                  DATETIME2 (7)  NULL,
    [end_date_time]                   DATETIME2 (7)  NULL,
    [engaged_party_description]       NVARCHAR (500) NULL,
    [engaged_party_id]                NVARCHAR (50)  NULL,
    [engaged_party_name]              NVARCHAR (500) NULL,
    [engaged_party_ref_type]          NVARCHAR (500) NULL,
    [extended_attributes]             NVARCHAR (MAX) NULL,
    [external_id]                     NVARCHAR (50)  NULL,
    [id]                              NVARCHAR (50)  NULL,
    [idempotency_key]                 NVARCHAR (500) NULL,
    [last_nps_survey_ref]             NVARCHAR (500) NULL,
    [name]                            NVARCHAR (500) NULL,
    [net_promoter_score]              NVARCHAR (500) NULL,
    [ola_ref]                         NVARCHAR (MAX) NULL,
    [op]                              NVARCHAR (500) NULL,
    [org_chart_ref]                   NVARCHAR (MAX) NULL,
    [portfolio]                       NVARCHAR (500) NULL,
    [start_date_time]                 DATETIME2 (7)  NULL,
    [status]                          NVARCHAR (500) NULL,
    [status_reason]                   NVARCHAR (500) NULL,
    [ts_ms]                           BIGINT         NULL,
    [Snapshot]                        NVARCHAR (500) NULL,
    [Partition_Snapshot]              NVARCHAR (500) NULL,
    [NUUDL_CuratedBatchID]            INT            NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (500) NULL,
    [NUUDL_IsCurrent]                 BIT            NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)  NULL,
    [NUUDL_ID]                        BIGINT         NOT NULL,
    [DWCreatedDate]                   DATETIME2 (7)  NULL,
    CONSTRAINT [PK_cimcustomer] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);




GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cimcustomer]
    ON [sourceNuudlDawn].[cimcustomer];


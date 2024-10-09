CREATE TABLE [sourceNuudlDawn].[qssnrmlquote] (
    [approval_level]                  NVARCHAR (4000) NULL,
    [assign_to]                       NVARCHAR (4000) NULL,
    [brand_id]                        NVARCHAR (50)   NULL,
    [business_action]                 NVARCHAR (4000) NULL,
    [cancellation_reason]             NVARCHAR (4000) NULL,
    [customer_category_id]            NVARCHAR (50)   NULL,
    [customer_committed_date]         DATETIME2 (7)   NULL,
    [customer_id]                     NVARCHAR (50)   NULL,
    [customer_requested_date]         DATETIME2 (7)   NULL,
    [delivery_method]                 NVARCHAR (4000) NULL,
    [distribution_channel_id]         NVARCHAR (50)   NULL,
    [expiration_date]                 DATETIME2 (7)   NULL,
    [extended_parameters]             NVARCHAR (MAX)  NULL,
    [external_id]                     NVARCHAR (50)   NULL,
    [id]                              NVARCHAR (50)   NULL,
    [initial_distribution_channel_id] NVARCHAR (50)   NULL,
    [name]                            NVARCHAR (4000) NULL,
    [new_msa]                         BIT             NULL,
    [number]                          DECIMAL (10)    NULL,
    [opportunity_id]                  NVARCHAR (50)   NULL,
    [override_mode]                   NVARCHAR (4000) NULL,
    [owner]                           NVARCHAR (4000) NULL,
    [price_list_id]                   NVARCHAR (50)   NULL,
    [quote_creation_date]             DATETIME2 (7)   NULL,
    [revision]                        DECIMAL (10)    NULL,
    [state]                           NVARCHAR (4000) NULL,
    [updated_when]                    DATETIME2 (7)   NULL,
    [version]                         NVARCHAR (4000) NULL,
    [state_change_reason]             NVARCHAR (4000) NULL,
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
    CONSTRAINT [PK_qssnrmlquote] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);






GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_qssnrmlquote]
    ON [sourceNuudlDawn].[qssnrmlquote];






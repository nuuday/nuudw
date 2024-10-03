CREATE TABLE [sourceNuudlDawn].[qssnrmlquote] (
    [approval_level]                  NVARCHAR (500)  NULL,
    [assign_to]                       NVARCHAR (500)  NULL,
    [brand_id]                        NVARCHAR (50)   NULL,
    [business_action]                 NVARCHAR (500)  NULL,
    [cancellation_reason]             NVARCHAR (500)  NULL,
    [customer_category_id]            NVARCHAR (50)   NULL,
    [customer_committed_date]         DATETIME2 (7)   NULL,
    [customer_id]                     NVARCHAR (50)   NULL,
    [customer_requested_date]         DATETIME2 (7)   NULL,
    [delivery_method]                 NVARCHAR (500)  NULL,
    [distribution_channel_id]         NVARCHAR (50)   NULL,
    [expiration_date]                 DATETIME2 (7)   NULL,
    [extended_parameters]             NVARCHAR (MAX)  NULL,
    [external_id]                     NVARCHAR (50)   NULL,
    [id]                              NVARCHAR (50)   NULL,
    [initial_distribution_channel_id] NVARCHAR (50)   NULL,
    [name]                            NVARCHAR (500)  NULL,
    [new_msa]                         BIT             NULL,
    [number]                          DECIMAL (10)    NULL,
    [op]                              NVARCHAR (500)  NULL,
    [opportunity_id]                  NVARCHAR (50)   NULL,
    [override_mode]                   NVARCHAR (500)  NULL,
    [owner]                           NVARCHAR (500)  NULL,
    [price_list_id]                   NVARCHAR (50)   NULL,
    [quote_creation_date]             DATETIME2 (7)   NULL,
    [revision]                        DECIMAL (10)    NULL,
    [state]                           NVARCHAR (500)  NULL,
    [state_change_reason]             NVARCHAR (500)  NULL,
    [ts_ms]                           BIGINT          NULL,
    [updated_when]                    DATETIME2 (7)   NULL,
    [version]                         NVARCHAR (500)  NULL,
    [NUUDL_CuratedBatchID]            INT             NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (500)  NULL,
    [NUUDL_IsCurrent]                 BIT             NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)   NULL,
    [NUUDL_ID]                        BIGINT          NOT NULL,
    [DWCreatedDate]                   DATETIME2 (7)   DEFAULT (getdate()) NULL,
    [NUUDL_IsDeleted]                 BIT             NULL,
    [NUUDL_DeleteType]                NVARCHAR (4000) NULL,
    [NUUDL_IsLatest]                  BIT             NULL,
    CONSTRAINT [PK_qssnrmlquote] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);




GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_qssnrmlquote]
    ON [sourceNuudlDawn].[qssnrmlquote];




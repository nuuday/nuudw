CREATE TABLE [sourceNuudlDawn].[qssnrmlquoteitempricealteration] (
    [action]                          NVARCHAR (4000) NULL,
    [application_duration]            DECIMAL (10)    NULL,
    [application_mode]                NVARCHAR (4000) NULL,
    [duration_units]                  NVARCHAR (4000) NULL,
    [extended_parameters]             NVARCHAR (MAX)  NULL,
    [id]                              NVARCHAR (50)   NULL,
    [op]                              NVARCHAR (4000) NULL,
    [overridden]                      BIT             NULL,
    [overridden_value]                NVARCHAR (4000) NULL,
    [override_type]                   NVARCHAR (4000) NULL,
    [price_alteration_type]           NVARCHAR (4000) NULL,
    [price_type]                      NVARCHAR (4000) NULL,
    [promo_action_id]                 NVARCHAR (50)   NULL,
    [promo_pattern_id]                NVARCHAR (50)   NULL,
    [quote_id]                        NVARCHAR (50)   NULL,
    [quote_item_id]                   NVARCHAR (50)   NULL,
    [quote_version]                   NVARCHAR (4000) NULL,
    [ts_ms]                           BIGINT          NULL,
    [valid_from]                      DATETIME2 (7)   NULL,
    [valid_to]                        DATETIME2 (7)   NULL,
    [value_excluding_tax]             NVARCHAR (4000) NULL,
    [value_including_tax]             NVARCHAR (4000) NULL,
    [NUUDL_CuratedBatchID]            INT             NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (4000) NULL,
    [NUUDL_IsCurrent]                 BIT             NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)   NULL,
    [NUUDL_ID]                        BIGINT          NOT NULL,
    [DWCreatedDate]                   DATETIME2 (7)   DEFAULT (getdate()) NULL,
    [NUUDL_IsDeleted]                 BIT             NULL,
    [NUUDL_DeleteType]                NVARCHAR (4000) NULL,
    [NUUDL_IsLatest]                  BIT             NULL,
    CONSTRAINT [PK_qssnrmlquoteitempricealteration] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);




GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_qssnrmlquoteitempricealteration]
    ON [sourceNuudlDawn].[qssnrmlquoteitempricealteration];




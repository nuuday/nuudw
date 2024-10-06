CREATE TABLE [sourceNuudlDawn].[qssnrmlquoteitemprice] (
    [approx_installment_payment_amount_excluding_tax] NVARCHAR (4000) NULL,
    [approx_installment_payment_amount_including_tax] NVARCHAR (4000) NULL,
    [down_payment_overridden]                         NVARCHAR (4000) NULL,
    [down_payment_value_excluding_tax]                NVARCHAR (4000) NULL,
    [down_payment_value_including_tax]                NVARCHAR (4000) NULL,
    [extended_parameters]                             NVARCHAR (MAX)  NULL,
    [overridden]                                      BIT             NULL,
    [overridden_value]                                NVARCHAR (4000) NULL,
    [override_type]                                   NVARCHAR (4000) NULL,
    [price_currency]                                  NVARCHAR (4000) NULL,
    [price_id]                                        NVARCHAR (50)   NULL,
    [price_plan_id]                                   NVARCHAR (50)   NULL,
    [price_specification_id]                          NVARCHAR (50)   NULL,
    [price_type]                                      NVARCHAR (4000) NULL,
    [quote_id]                                        NVARCHAR (50)   NULL,
    [quote_item_id]                                   NVARCHAR (50)   NULL,
    [quote_version]                                   NVARCHAR (4000) NULL,
    [tax_rate]                                        NVARCHAR (4000) NULL,
    [value_base_price_excluding_tax]                  NVARCHAR (4000) NULL,
    [value_base_price_including_tax]                  NVARCHAR (4000) NULL,
    [value_excluding_tax]                             NVARCHAR (4000) NULL,
    [value_including_tax]                             NVARCHAR (4000) NULL,
    [value_sub_total_price_excluding_tax]             NVARCHAR (4000) NULL,
    [value_sub_total_price_including_tax]             NVARCHAR (4000) NULL,
    [ts_ms]                                           BIGINT          NULL,
    [lsn]                                             BIGINT          NULL,
    [op]                                              NVARCHAR (4000) NULL,
    [NUUDL_IsCurrent]                                 BIT             NULL,
    [NUUDL_ValidFrom]                                 DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]                                   DATETIME2 (7)   NULL,
    [NUUDL_CuratedBatchID]                            INT             NULL,
    [NUUDL_CuratedProcessedTimestamp]                 NVARCHAR (4000) NULL,
    [NUUDL_IsDeleted]                                 BIT             NULL,
    [NUUDL_DeleteType]                                NVARCHAR (4000) NULL,
    [NUUDL_ID]                                        BIGINT          NOT NULL,
    [NUUDL_IsLatest]                                  BIT             NULL,
    [DWCreatedDate]                                   DATETIME2 (7)   DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_qssnrmlquoteitemprice] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);






GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_qssnrmlquoteitemprice]
    ON [sourceNuudlDawn].[qssnrmlquoteitemprice];






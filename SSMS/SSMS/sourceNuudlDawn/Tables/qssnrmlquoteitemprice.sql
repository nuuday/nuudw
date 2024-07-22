﻿CREATE TABLE [sourceNuudlDawn].[qssnrmlquoteitemprice] (
    [approx_installment_payment_amount_excluding_tax] NVARCHAR (500) NULL,
    [approx_installment_payment_amount_including_tax] NVARCHAR (500) NULL,
    [down_payment_overridden]                         BIT            NULL,
    [down_payment_value_excluding_tax]                NVARCHAR (500) NULL,
    [down_payment_value_including_tax]                NVARCHAR (500) NULL,
    [extended_parameters]                             NVARCHAR (MAX) NULL,
    [op]                                              NVARCHAR (500) NULL,
    [overridden]                                      BIT            NULL,
    [overridden_value]                                NVARCHAR (500) NULL,
    [override_type]                                   NVARCHAR (500) NULL,
    [price_currency]                                  NVARCHAR (500) NULL,
    [price_id]                                        NVARCHAR (50)  NULL,
    [price_plan_id]                                   NVARCHAR (50)  NULL,
    [price_specification_id]                          NVARCHAR (50)  NULL,
    [price_type]                                      NVARCHAR (500) NULL,
    [quote_id]                                        NVARCHAR (50)  NULL,
    [quote_item_id]                                   NVARCHAR (50)  NULL,
    [quote_version]                                   NVARCHAR (500) NULL,
    [tax_rate]                                        NVARCHAR (500) NULL,
    [ts_ms]                                           BIGINT         NULL,
    [value_base_price_excluding_tax]                  NVARCHAR (500) NULL,
    [value_base_price_including_tax]                  NVARCHAR (500) NULL,
    [value_excluding_tax]                             NVARCHAR (500) NULL,
    [value_including_tax]                             NVARCHAR (500) NULL,
    [value_sub_total_price_excluding_tax]             NVARCHAR (500) NULL,
    [value_sub_total_price_including_tax]             NVARCHAR (500) NULL,
    [NUUDL_CuratedBatchID]                            INT            NULL,
    [NUUDL_CuratedProcessedTimestamp]                 NVARCHAR (500) NULL,
    [NUUDL_IsCurrent]                                 BIT            NULL,
    [NUUDL_ValidFrom]                                 DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                                   DATETIME2 (7)  NULL,
    [NUUDL_ID]                                        BIGINT         NOT NULL,
    [DWCreatedDate]                                   DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_qssnrmlquoteitemprice] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_qssnrmlquoteitemprice]
    ON [sourceNuudlDawn].[qssnrmlquoteitemprice];


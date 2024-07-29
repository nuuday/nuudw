﻿CREATE TABLE [sourceNuudlNetCracker].[pimnrmlproductofferingpricechargeitem] (
    [amount]                                        DECIMAL (10)    NULL,
    [applied_from]                                  DATETIME2 (7)   NULL,
    [applied_to]                                    DATETIME2 (7)   NULL,
    [down_payment_amount]                           DECIMAL (10)    NULL,
    [id]                                            NVARCHAR (50)   NULL,
    [is_overridable]                                BIT             NULL,
    [price_key_id]                                  NVARCHAR (50)   NULL,
    [cdc_revision_id]                               NVARCHAR (50)   NULL,
    [context_top_offering_ids_json__corrupt_record] NVARCHAR (4000) NULL,
    [NUUDL_ValidFrom]                               DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]                                 DATETIME2 (7)   NULL,
    [NUUDL_IsCurrent]                               BIT             NULL,
    [NUUDL_ID]                                      BIGINT          NOT NULL,
    [NUUDL_CuratedBatchID]                          INT             NULL,
    [NUUDL_CuratedProcessedTimestamp]               NVARCHAR (4000) NULL,
    [DWCreatedDate]                                 DATETIME2 (7)   DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_pimnrmlproductofferingpricechargeitem] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_pimnrmlproductofferingpricechargeitem]
    ON [sourceNuudlNetCracker].[pimnrmlproductofferingpricechargeitem];


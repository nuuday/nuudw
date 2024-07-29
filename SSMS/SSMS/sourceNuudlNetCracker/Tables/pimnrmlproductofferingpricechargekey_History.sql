CREATE TABLE [sourceNuudlNetCracker].[pimnrmlproductofferingpricechargekey_History] (
    [available_from]                                                DATETIME2 (7)   NULL,
    [available_to]                                                  DATETIME2 (7)   NULL,
    [currency_id]                                                   NVARCHAR (50)   NULL,
    [localized_name]                                                NVARCHAR (4000) NULL,
    [id]                                                            NVARCHAR (50)   NULL,
    [is_base]                                                       BIT             NULL,
    [is_default]                                                    BIT             NULL,
    [name]                                                          NVARCHAR (4000) NULL,
    [price_list_id]                                                 NVARCHAR (50)   NULL,
    [prod_offering_price_spec_id]                                   NVARCHAR (50)   NULL,
    [alternate_price_key_id]                                        NVARCHAR (50)   NULL,
    [external_id]                                                   NVARCHAR (50)   NULL,
    [prod_offering_id]                                              NVARCHAR (50)   NULL,
    [tangible_product_sale_type_id]                                 NVARCHAR (50)   NULL,
    [installment_plan_id]                                           NVARCHAR (50)   NULL,
    [price_eligibility_condition_id]                                NVARCHAR (50)   NULL,
    [cdc_revision_id]                                               NVARCHAR (50)   NULL,
    [prod_offering_price_policy_condition_ids_json__corrupt_record] NVARCHAR (4000) NULL,
    [NUUDL_ValidFrom]                                               DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]                                                 DATETIME2 (7)   NULL,
    [NUUDL_IsCurrent]                                               BIT             NULL,
    [NUUDL_ID]                                                      BIGINT          NOT NULL,
    [NUUDL_CuratedBatchID]                                          INT             NULL,
    [NUUDL_CuratedProcessedTimestamp]                               NVARCHAR (4000) NULL,
    [DWIsCurrent]                                                   BIT             NULL,
    [DWValidFromDate]                                               DATETIME2 (7)   NOT NULL,
    [DWValidToDate]                                                 DATETIME2 (7)   NULL,
    [DWCreatedDate]                                                 DATETIME2 (7)   NULL,
    [DWModifiedDate]                                                DATETIME2 (7)   NULL,
    [DWIsDeletedInSource]                                           BIT             NULL,
    [DWDeletedInSourceDate]                                         DATETIME2 (7)   NULL,
    CONSTRAINT [PK_pimnrmlproductofferingpricechargekey_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_pimnrmlproductofferingpricechargekey_History]
    ON [sourceNuudlNetCracker].[pimnrmlproductofferingpricechargekey_History];


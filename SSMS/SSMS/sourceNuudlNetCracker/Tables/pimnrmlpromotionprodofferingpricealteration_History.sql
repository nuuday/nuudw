CREATE TABLE [sourceNuudlNetCracker].[pimnrmlpromotionprodofferingpricealteration_History] (
    [amount]                               DECIMAL (10)    NULL,
    [amount_percentage]                    DECIMAL (10)    NULL,
    [currency_id]                          NVARCHAR (50)   NULL,
    [id]                                   NVARCHAR (50)   NULL,
    [name]                                 NVARCHAR (4000) NULL,
    [prod_offering_price_specification_id] NVARCHAR (50)   NULL,
    [extended_parameters]                  NVARCHAR (4000) NULL,
    [cdc_revision_id]                      NVARCHAR (50)   NULL,
    [localized_name_json_dan]              NVARCHAR (4000) NULL,
    [NUUDL_ValidFrom]                      DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]                        DATETIME2 (7)   NULL,
    [NUUDL_IsCurrent]                      BIT             NULL,
    [NUUDL_ID]                             BIGINT          NOT NULL,
    [NUUDL_CuratedBatchID]                 INT             NULL,
    [NUUDL_CuratedProcessedTimestamp]      NVARCHAR (4000) NULL,
    [DWIsCurrent]                          BIT             NULL,
    [DWValidFromDate]                      DATETIME2 (7)   NOT NULL,
    [DWValidToDate]                        DATETIME2 (7)   NULL,
    [DWCreatedDate]                        DATETIME2 (7)   NULL,
    [DWModifiedDate]                       DATETIME2 (7)   NULL,
    [DWIsDeletedInSource]                  BIT             NULL,
    [DWDeletedInSourceDate]                DATETIME2 (7)   NULL,
    CONSTRAINT [PK_pimnrmlpromotionprodofferingpricealteration_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_pimnrmlpromotionprodofferingpricealteration_History]
    ON [sourceNuudlNetCracker].[pimnrmlpromotionprodofferingpricealteration_History];


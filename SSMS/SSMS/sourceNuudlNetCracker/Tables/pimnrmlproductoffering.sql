CREATE TABLE [sourceNuudlNetCracker].[pimnrmlproductoffering] (
    [available_from]                                      DATETIME2 (7)  NULL,
    [available_to]                                        DATETIME2 (7)  NULL,
    [localized_name_json_dan]                             NVARCHAR (300) NULL,
    [id]                                                  NVARCHAR (36)  NULL,
    [is_active]                                           BIT            NULL,
    [name]                                                NVARCHAR (300) NULL,
    [product_family_id]                                   NVARCHAR (36)  NULL,
    [product_offering_charging_type]                      NVARCHAR (300) NULL,
    [sku_id]                                              NVARCHAR (36)  NULL,
    [tags_json__corrupt_record]                           NVARCHAR (300) NULL,
    [weight]                                              INT            NULL,
    [external_id]                                         NVARCHAR (36)  NULL,
    [extended_parameters_json__corrupt_record]            NVARCHAR (300) NULL,
    [extended_parameters_json_deviceType]                 NVARCHAR (300) NULL,
    [extended_parameters_json_migrationId]                NVARCHAR (36)  NULL,
    [extended_parameters_json_mobileAddOnType]            NVARCHAR (300) NULL,
    [extended_parameters_json_noInWarehouse]              NVARCHAR (300) NULL,
    [extended_parameters_json_NumberInWarehouse]          NVARCHAR (300) NULL,
    [extended_parameters_json_offeringBusinessType]       NVARCHAR (300) NULL,
    [extended_parameters_json_offeringBusinessUse]        NVARCHAR (300) NULL,
    [extended_parameters_json_phoneNumberOfferingType]    NVARCHAR (300) NULL,
    [extended_parameters_json_simOfferingType]            NVARCHAR (300) NULL,
    [extended_parameters_json_termsConditionsType]        NVARCHAR (300) NULL,
    [tangible_product_id]                                 NVARCHAR (36)  NULL,
    [included_brand_json__corrupt_record]                 NVARCHAR (300) NULL,
    [included_customer_categories_json__corrupt_record]   NVARCHAR (300) NULL,
    [included_distribution_channels_json__corrupt_record] NVARCHAR (300) NULL,
    [included_markets_json__corrupt_record]               NVARCHAR (300) NULL,
    [excluded_markets]                                    NVARCHAR (300) NULL,
    [excluded_customer_categories]                        NVARCHAR (300) NULL,
    [excluded_distribution_channels]                      NVARCHAR (300) NULL,
    [product_specification_id]                            NVARCHAR (36)  NULL,
    [cdc_revision_id]                                     NVARCHAR (36)  NULL,
    [is_current]                                          BIT            NULL,
    [NUUDL_ValidFrom]                                     DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                                       DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]                                     BIT            NULL,
    [NUUDL_ID]                                            BIGINT         NOT NULL,
    [NUUDL_CuratedBatchID]                                BIGINT         NULL,
    [DWCreatedDate]                                       DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_pimnrmlproductoffering] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_pimnrmlproductoffering]
    ON [sourceNuudlNetCracker].[pimnrmlproductoffering];


CREATE TABLE [sourceDataLakeNetcracker_interim].[product_offering] (
    [available_from]                 NVARCHAR (500) NULL,
    [available_to]                   NVARCHAR (500) NULL,
    [localized_name]                 NVARCHAR (500) NULL,
    [id]                             NVARCHAR (500) NULL,
    [is_active]                      BIT            NULL,
    [name]                           NVARCHAR (500) NULL,
    [product_family_id]              NVARCHAR (500) NULL,
    [product_offering_charging_type] NVARCHAR (500) NULL,
    [sku_id]                         NVARCHAR (500) NULL,
    [tags]                           NVARCHAR (500) NULL,
    [weight]                         INT            NULL,
    [external_id]                    NVARCHAR (500) NULL,
    [extended_parameters]            NVARCHAR (500) NULL,
    [tangible_product_id]            NVARCHAR (500) NULL,
    [included_brand]                 NVARCHAR (500) NULL,
    [included_markets]               NVARCHAR (500) NULL,
    [excluded_markets]               NVARCHAR (500) NULL,
    [included_customer_categories]   NVARCHAR (500) NULL,
    [excluded_customer_categories]   NVARCHAR (500) NULL,
    [included_distribution_channels] NVARCHAR (500) NULL,
    [excluded_distribution_channels] NVARCHAR (500) NULL,
    [product_specification_id]       NVARCHAR (500) NULL,
    [cdc_revision_id]                NVARCHAR (500) NULL,
    [DWCreatedDate]                  DATETIME       DEFAULT (getdate()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'TruncateBeforeDeploy', @value = N'True', @level0type = N'SCHEMA', @level0name = N'sourceDataLakeNetcracker_interim', @level1type = N'TABLE', @level1name = N'product_offering';


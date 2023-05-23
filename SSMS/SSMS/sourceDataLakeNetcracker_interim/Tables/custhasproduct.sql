CREATE TABLE [sourceDataLakeNetcracker_interim].[custhasproduct] (
    [customer_ref]                   NVARCHAR (500) NULL,
    [product_seq]                    INT            NULL,
    [product_id]                     INT            NULL,
    [package_seq]                    INT            NULL,
    [product_package_instance]       INT            NULL,
    [parent_product_seq]             INT            NULL,
    [successor_product_seq]          INT            NULL,
    [cust_order_num]                 NVARCHAR (500) NULL,
    [supplier_order_num]             NVARCHAR (500) NULL,
    [suppress_init_charge_boo]       NVARCHAR (500) NULL,
    [suppress_term_charge_boo]       NVARCHAR (500) NULL,
    [suppress_early_term_charge_boo] NVARCHAR (500) NULL,
    [event_source_count]             INT            NULL,
    [subscription_boo]               NVARCHAR (500) NULL,
    [subs_product_seq]               INT            NULL,
    [subscription_ref]               NVARCHAR (500) NULL,
    [template_optional_prod_boo]     NVARCHAR (500) NULL,
    [structural_integer_ref]         INT            NULL,
    [template_seq]                   INT            NULL,
    [catalogue_changed_dtm]          NVARCHAR (500) NULL,
    [has_add_on_products_boo]        NVARCHAR (500) NULL,
    [domain_id]                      INT            NULL,
    [transfer_indicator]             INT            NULL,
    [actual_product_start_dtm]       NVARCHAR (500) NULL,
    [has_descendants_boo]            NVARCHAR (500) NULL,
    [client_entity_tag]              NVARCHAR (500) NULL,
    [tax_status_change_date]         NVARCHAR (500) NULL,
    [DWCreatedDate]                  DATETIME       DEFAULT (getdate()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'TruncateBeforeDeploy', @value = N'True', @level0type = N'SCHEMA', @level0name = N'sourceDataLakeNetcracker_interim', @level1type = N'TABLE', @level1name = N'custhasproduct';


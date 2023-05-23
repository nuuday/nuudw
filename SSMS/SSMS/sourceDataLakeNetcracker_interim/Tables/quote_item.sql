CREATE TABLE [sourceDataLakeNetcracker_interim].[quote_item] (
    [account_id]                    NVARCHAR (500) NULL,
    [action]                        NVARCHAR (500) NULL,
    [active_from]                   NVARCHAR (500) NULL,
    [active_to]                     NVARCHAR (500) NULL,
    [amount]                        NVARCHAR (500) NULL,
    [approval_level]                NVARCHAR (500) NULL,
    [availability_check_result]     NVARCHAR (500) NULL,
    [business_action]               NVARCHAR (500) NULL,
    [business_group_id]             NVARCHAR (500) NULL,
    [business_group_name]           NVARCHAR (500) NULL,
    [contracted_date]               NVARCHAR (500) NULL,
    [creation_time]                 NVARCHAR (500) NULL,
    [disconnection_reason]          NVARCHAR (500) NULL,
    [distribution_channel_id]       NVARCHAR (500) NULL,
    [extended_parameters]           NVARCHAR (500) NULL,
    [geo_site_id]                   NVARCHAR (500) NULL,
    [id]                            NVARCHAR (500) NULL,
    [market_id]                     NVARCHAR (500) NULL,
    [marketing_bundle_id]           NVARCHAR (500) NULL,
    [number_of_installments]        NVARCHAR (500) NULL,
    [parent_quote_item_id]          NVARCHAR (500) NULL,
    [planned_disconnection_date]    NVARCHAR (500) NULL,
    [product_instance_id]           NVARCHAR (500) NULL,
    [product_offering_id]           NVARCHAR (500) NULL,
    [product_specification_id]      NVARCHAR (500) NULL,
    [product_specification_version] NVARCHAR (500) NULL,
    [quantity]                      INT            NULL,
    [quote_id]                      NVARCHAR (500) NULL,
    [root_quote_item_id]            NVARCHAR (500) NULL,
    [state]                         NVARCHAR (500) NULL,
    [quote_version]                 NVARCHAR (500) NULL,
    [is_deleted]                    BIT            NULL,
    [last_modified_ts]              NVARCHAR (500) NULL,
    [DWCreatedDate]                 DATETIME       DEFAULT (getdate()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'TruncateBeforeDeploy', @value = N'True', @level0type = N'SCHEMA', @level0name = N'sourceDataLakeNetcracker_interim', @level1type = N'TABLE', @level1name = N'quote_item';


CREATE TABLE [sourceDataLakeNetcracker_interim].[quote] (
    [approval_level]                  NVARCHAR (500) NULL,
    [assign_to]                       NVARCHAR (500) NULL,
    [brand_id]                        NVARCHAR (500) NULL,
    [business_action]                 NVARCHAR (500) NULL,
    [cancellation_reason]             NVARCHAR (500) NULL,
    [customer_category_id]            NVARCHAR (500) NULL,
    [customer_committed_date]         NVARCHAR (500) NULL,
    [customer_id]                     NVARCHAR (500) NULL,
    [customer_requested_date]         NVARCHAR (500) NULL,
    [delivery_method]                 NVARCHAR (500) NULL,
    [distribution_channel_id]         NVARCHAR (500) NULL,
    [expiration_date]                 NVARCHAR (500) NULL,
    [extended_parameters]             NVARCHAR (500) NULL,
    [external_id]                     NVARCHAR (500) NULL,
    [id]                              NVARCHAR (500) NULL,
    [initial_distribution_channel_id] NVARCHAR (500) NULL,
    [name]                            NVARCHAR (500) NULL,
    [new_msa]                         BIT            NULL,
    [number]                          NVARCHAR (500) NULL,
    [opportunity_id]                  NVARCHAR (500) NULL,
    [override_mode]                   NVARCHAR (500) NULL,
    [owner]                           NVARCHAR (500) NULL,
    [price_list_id]                   NVARCHAR (500) NULL,
    [quote_creation_date]             NVARCHAR (500) NULL,
    [revision]                        NVARCHAR (500) NULL,
    [state]                           NVARCHAR (500) NULL,
    [updated_when]                    NVARCHAR (500) NULL,
    [version]                         NVARCHAR (500) NULL,
    [is_deleted]                      BIT            NULL,
    [last_modified_ts]                NVARCHAR (500) NULL,
    [DWCreatedDate]                   DATETIME       DEFAULT (getdate()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'TruncateBeforeDeploy', @value = N'True', @level0type = N'SCHEMA', @level0name = N'sourceDataLakeNetcracker_interim', @level1type = N'TABLE', @level1name = N'quote';


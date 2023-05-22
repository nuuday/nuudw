CREATE TABLE [sourceDataLakeNetcracker_interim].[phone_numbers] (
    [phone_number]                BIGINT         NULL,
    [description]                 NVARCHAR (500) NULL,
    [status]                      NVARCHAR (500) NULL,
    [category]                    NVARCHAR (500) NULL,
    [perform_auto_categorization] BIT            NULL,
    [serving_switch_id]           NVARCHAR (500) NULL,
    [top_range_id]                NVARCHAR (500) NULL,
    [subrange_id]                 NVARCHAR (500) NULL,
    [reservation_id]              NVARCHAR (500) NULL,
    [customer_account_id]         NVARCHAR (500) NULL,
    [ported_in]                   BIT            NULL,
    [ported_out]                  BIT            NULL,
    [metadata]                    NVARCHAR (500) NULL,
    [aging_period_end_date]       NVARCHAR (500) NULL,
    [status_change_date]          NVARCHAR (500) NULL,
    [created_at]                  NVARCHAR (500) NULL,
    [modified_at]                 NVARCHAR (500) NULL,
    [first_owner_id]              NVARCHAR (500) NULL,
    [ported_in_from]              NVARCHAR (500) NULL,
    [ported_out_to]               NVARCHAR (500) NULL,
    [country_code]                NVARCHAR (500) NULL,
    [area_code]                   NVARCHAR (500) NULL,
    [national_prefix]             NVARCHAR (500) NULL,
    [is_deleted]                  BIT            NULL,
    [last_modified_ts]            NVARCHAR (500) NULL,
    [DWCreatedDate]               DATETIME       DEFAULT (getdate()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'TruncateBeforeDeploy', @value = N'True', @level0type = N'SCHEMA', @level0name = N'sourceDataLakeNetcracker_interim', @level1type = N'TABLE', @level1name = N'phone_numbers';


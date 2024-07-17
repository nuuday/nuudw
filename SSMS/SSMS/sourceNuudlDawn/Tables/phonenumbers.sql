CREATE TABLE [sourceNuudlDawn].[phonenumbers] (
    [aging_period_end_date]           DATETIME2 (7)  NULL,
    [area_code]                       NVARCHAR (500) NULL,
    [category]                        NVARCHAR (500) NULL,
    [country_code]                    NVARCHAR (500) NULL,
    [customer_account_id]             NVARCHAR (50)  NULL,
    [description]                     NVARCHAR (MAX) NULL,
    [extended_parameters]             NVARCHAR (MAX) NULL,
    [first_owner_id]                  NVARCHAR (50)  NULL,
    [national_prefix]                 NVARCHAR (500) NULL,
    [op]                              NVARCHAR (500) NULL,
    [perform_auto_categorization]     BIT            NULL,
    [phone_number]                    BIGINT         NULL,
    [ported_in]                       BIT            NULL,
    [ported_in_from]                  NVARCHAR (500) NULL,
    [ported_out]                      BIT            NULL,
    [ported_out_to]                   NVARCHAR (500) NULL,
    [serving_switch_id]               NVARCHAR (50)  NULL,
    [status]                          NVARCHAR (500) NULL,
    [status_change_date]              DATETIME2 (7)  NULL,
    [subrange_id]                     NVARCHAR (50)  NULL,
    [top_range_id]                    NVARCHAR (50)  NULL,
    [ts_ms]                           BIGINT         NULL,
    [NUUDL_CuratedBatchID]            INT            NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (500) NULL,
    [NUUDL_IsCurrent]                 BIT            NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)  NULL,
    [NUUDL_ID]                        BIGINT         NOT NULL,
    [DWCreatedDate]                   DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_phonenumbers] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_phonenumbers]
    ON [sourceNuudlDawn].[phonenumbers];


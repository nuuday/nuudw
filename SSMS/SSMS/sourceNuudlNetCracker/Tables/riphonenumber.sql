CREATE TABLE [sourceNuudlNetCracker].[riphonenumber] (
    [phone_number]                             NVARCHAR (300) NULL,
    [description]                              NVARCHAR (300) NULL,
    [status]                                   NVARCHAR (300) NULL,
    [category]                                 NVARCHAR (300) NULL,
    [perform_auto_categorization]              BIT            NULL,
    [serving_switch_id]                        NVARCHAR (36)  NULL,
    [top_range_id]                             NVARCHAR (36)  NULL,
    [subrange_id]                              NVARCHAR (36)  NULL,
    [customer_account_id]                      NVARCHAR (36)  NULL,
    [ported_in]                                BIT            NULL,
    [ported_out]                               BIT            NULL,
    [extended_parameters_json__corrupt_record] NVARCHAR (300) NULL,
    [aging_period_end_date]                    DATE           NULL,
    [status_change_date]                       DATETIME2 (7)  NULL,
    [first_owner_id]                           NVARCHAR (36)  NULL,
    [ported_in_from]                           NVARCHAR (300) NULL,
    [ported_out_to]                            NVARCHAR (300) NULL,
    [country_code]                             NVARCHAR (300) NULL,
    [area_code]                                NVARCHAR (300) NULL,
    [national_prefix]                          NVARCHAR (300) NULL,
    [is_deleted]                               BIT            NULL,
    [last_modified_ts]                         DATETIME2 (7)  NULL,
    [is_current]                               BIT            NULL,
    [extended_parameters_json_brand_id]        NVARCHAR (36)  NULL,
    [extended_parameters_json_sp_id]           NVARCHAR (36)  NULL,
    [NUUDL_ValidFrom]                          DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                            DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]                          BIT            NULL,
    [NUUDL_ID]                                 BIGINT         NOT NULL,
    [NUUDL_CuratedBatchID]                     BIGINT         NULL,
    [DWCreatedDate]                            DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_riphonenumber] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_riphonenumber]
    ON [sourceNuudlNetCracker].[riphonenumber];


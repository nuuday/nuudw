CREATE TABLE [sourceNuudlDawn].[phonenumbers] (
    [aging_period_end_date]           NVARCHAR (4000) NULL,
    [area_code]                       NVARCHAR (4000) NULL,
    [category]                        NVARCHAR (4000) NULL,
    [country_code]                    NVARCHAR (4000) NULL,
    [customer_account_id]             NVARCHAR (50)   NULL,
    [description]                     NVARCHAR (MAX)  NULL,
    [extended_parameters]             NVARCHAR (MAX)  NULL,
    [first_owner_id]                  NVARCHAR (50)   NULL,
    [national_prefix]                 NVARCHAR (4000) NULL,
    [perform_auto_categorization]     NVARCHAR (4000) NULL,
    [phone_number]                    NVARCHAR (4000) NULL,
    [ported_in]                       NVARCHAR (4000) NULL,
    [ported_in_from]                  NVARCHAR (4000) NULL,
    [ported_out]                      NVARCHAR (4000) NULL,
    [ported_out_to]                   NVARCHAR (4000) NULL,
    [serving_switch_id]               NVARCHAR (50)   NULL,
    [status]                          NVARCHAR (4000) NULL,
    [status_change_date]              DATETIME2 (7)   NULL,
    [subrange_id]                     NVARCHAR (50)   NULL,
    [top_range_id]                    NVARCHAR (50)   NULL,
    [ts_ms]                           BIGINT          NULL,
    [lsn]                             BIGINT          NULL,
    [op]                              NVARCHAR (4000) NULL,
    [NUUDL_IsCurrent]                 BIT             NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)   NULL,
    [NUUDL_CuratedBatchID]            INT             NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (4000) NULL,
    [NUUDL_IsDeleted]                 BIT             NULL,
    [NUUDL_DeleteType]                NVARCHAR (4000) NULL,
    [NUUDL_ID]                        BIGINT          NOT NULL,
    [NUUDL_IsLatest]                  BIT             NULL,
    [DWCreatedDate]                   DATETIME2 (7)   DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_phonenumbers] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);






GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_phonenumbers]
    ON [sourceNuudlDawn].[phonenumbers];






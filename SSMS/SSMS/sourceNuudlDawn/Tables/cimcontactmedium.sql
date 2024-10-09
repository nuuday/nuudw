CREATE TABLE [sourceNuudlDawn].[cimcontactmedium] (
    [active_from]                     DATETIME2 (7)   NULL,
    [billing_data]                    NVARCHAR (MAX)  NULL,
    [changed_by]                      NVARCHAR (MAX)  NULL,
    [city]                            NVARCHAR (4000) NULL,
    [contact_hour]                    NVARCHAR (MAX)  NULL,
    [country]                         NVARCHAR (4000) NULL,
    [email_address]                   NVARCHAR (4000) NULL,
    [end_date_time]                   DATETIME2 (7)   NULL,
    [extended_attributes]             NVARCHAR (MAX)  NULL,
    [fax_number]                      NVARCHAR (4000) NULL,
    [id]                              NVARCHAR (50)   NULL,
    [is_active]                       BIT             NULL,
    [phone_ext_number]                NVARCHAR (4000) NULL,
    [phone_number]                    NVARCHAR (4000) NULL,
    [postcode]                        NVARCHAR (4000) NULL,
    [preferred_contact]               BIT             NULL,
    [preferred_notification]          BIT             NULL,
    [push_notification_group_key]     NVARCHAR (4000) NULL,
    [ref_id]                          NVARCHAR (50)   NULL,
    [ref_type]                        NVARCHAR (4000) NULL,
    [social_network_id]               NVARCHAR (50)   NULL,
    [start_date_time]                 DATETIME2 (7)   NULL,
    [state_or_province]               NVARCHAR (4000) NULL,
    [street1]                         NVARCHAR (4000) NULL,
    [street2]                         NVARCHAR (4000) NULL,
    [type_of_contact]                 NVARCHAR (4000) NULL,
    [type_of_contact_method]          NVARCHAR (4000) NULL,
    [ts_ms]                           BIGINT          NULL,
    [lsn]                             BIGINT          NULL,
    [op]                              NVARCHAR (4000) NULL,
    [extended_attributes_floor]       NVARCHAR (4000) NULL,
    [extended_attributes_suite]       NVARCHAR (4000) NULL,
    [NUUDL_IsCurrent]                 BIT             NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)   NULL,
    [NUUDL_CuratedBatchID]            INT             NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (4000) NULL,
    [NUUDL_IsDeleted]                 BIT             NULL,
    [NUUDL_DeleteType]                NVARCHAR (4000) NULL,
    [NUUDL_IsLatest]                  BIT             NULL,
    [NUUDL_ID]                        BIGINT          NOT NULL,
    [DWCreatedDate]                   DATETIME2 (7)   DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_cimcontactmedium] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);






GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cimcontactmedium]
    ON [sourceNuudlDawn].[cimcontactmedium];






CREATE TABLE [sourceNuudlDawn].[cimcontactmedium] (
    [active_from]                     DATETIME2 (7)  NULL,
    [billing_data]                    NVARCHAR (MAX) NULL,
    [changed_by]                      NVARCHAR (MAX) NULL,
    [city]                            NVARCHAR (500) NULL,
    [contact_hour]                    NVARCHAR (MAX) NULL,
    [country]                         NVARCHAR (500) NULL,
    [email_address]                   NVARCHAR (500) NULL,
    [end_date_time]                   DATETIME2 (7)  NULL,
    [extended_attributes]             NVARCHAR (MAX) NULL,
    [fax_number]                      NVARCHAR (500) NULL,
    [id]                              NVARCHAR (50)  NULL,
    [is_active]                       BIT            NULL,
    [op]                              NVARCHAR (500) NULL,
    [phone_ext_number]                NVARCHAR (500) NULL,
    [phone_number]                    NVARCHAR (500) NULL,
    [postcode]                        NVARCHAR (500) NULL,
    [preferred_contact]               BIT            NULL,
    [preferred_notification]          BIT            NULL,
    [push_notification_group_key]     NVARCHAR (500) NULL,
    [ref_id]                          NVARCHAR (50)  NULL,
    [ref_type]                        NVARCHAR (500) NULL,
    [social_network_id]               NVARCHAR (50)  NULL,
    [start_date_time]                 DATETIME2 (7)  NULL,
    [state_or_province]               NVARCHAR (500) NULL,
    [street1]                         NVARCHAR (500) NULL,
    [street2]                         NVARCHAR (500) NULL,
    [ts_ms]                           BIGINT         NULL,
    [type_of_contact]                 NVARCHAR (500) NULL,
    [type_of_contact_method]          NVARCHAR (500) NULL,
    [Snapshot]                        NVARCHAR (500) NULL,
    [Partition_Snapshot]              NVARCHAR (500) NULL,
    [NUUDL_CuratedBatchID]            INT            NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (500) NULL,
    [NUUDL_IsCurrent]                 BIT            NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)  NULL,
    [NUUDL_ID]                        BIGINT         NOT NULL,
    [DWCreatedDate]                   DATETIME2 (7)  NULL,
    CONSTRAINT [PK_cimcontactmedium] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);




GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cimcontactmedium]
    ON [sourceNuudlDawn].[cimcontactmedium];




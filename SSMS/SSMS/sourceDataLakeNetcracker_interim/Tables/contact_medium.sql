CREATE TABLE [sourceDataLakeNetcracker_interim].[contact_medium] (
    [id]                     NVARCHAR (500) NULL,
    [city]                   NVARCHAR (500) NULL,
    [country]                NVARCHAR (500) NULL,
    [email_address]          NVARCHAR (500) NULL,
    [phone_number]           NVARCHAR (500) NULL,
    [fax_number]             NVARCHAR (500) NULL,
    [phone_ext_number]       NVARCHAR (500) NULL,
    [postcode]               NVARCHAR (500) NULL,
    [state_or_province]      NVARCHAR (500) NULL,
    [street1]                NVARCHAR (500) NULL,
    [street2]                NVARCHAR (500) NULL,
    [type_of_contact]        NVARCHAR (500) NULL,
    [type_of_contact_method] NVARCHAR (500) NULL,
    [is_active]              BIT            NULL,
    [active_from]            NVARCHAR (500) NULL,
    [ref_type]               NVARCHAR (500) NULL,
    [ref_id]                 NVARCHAR (500) NULL,
    [extended_attributes]    NVARCHAR (500) NULL,
    [contact_hour]           NVARCHAR (500) NULL,
    [changed_by]             NVARCHAR (500) NULL,
    [start_date_time]        NVARCHAR (500) NULL,
    [end_date_time]          NVARCHAR (500) NULL,
    [preferred_contact]      BIT            NULL,
    [preferred_notification] BIT            NULL,
    [billing_data]           NVARCHAR (500) NULL,
    [social_network_id]      NVARCHAR (500) NULL,
    [is_deleted]             BIT            NULL,
    [last_modified_ts]       NVARCHAR (500) NULL,
    [active_to]              NVARCHAR (500) NULL,
    [version]                INT            NULL,
    [DWCreatedDate]          DATETIME       DEFAULT (getdate()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'TruncateBeforeDeploy', @value = N'True', @level0type = N'SCHEMA', @level0name = N'sourceDataLakeNetcracker_interim', @level1type = N'TABLE', @level1name = N'contact_medium';


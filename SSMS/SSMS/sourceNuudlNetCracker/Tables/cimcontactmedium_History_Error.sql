﻿CREATE TABLE [sourceNuudlNetCracker].[cimcontactmedium_History_Error] (
    [ErrorMessage]                              NVARCHAR (100) NULL,
    [id]                                        NVARCHAR (36)  NULL,
    [city]                                      NVARCHAR (300) NULL,
    [country]                                   NVARCHAR (300) NULL,
    [email_address]                             NVARCHAR (300) NULL,
    [phone_ext_number]                          NVARCHAR (300) NULL,
    [fax_number]                                NVARCHAR (300) NULL,
    [postcode]                                  NVARCHAR (300) NULL,
    [state_or_province]                         NVARCHAR (300) NULL,
    [street1]                                   NVARCHAR (300) NULL,
    [street2]                                   NVARCHAR (300) NULL,
    [type_of_contact]                           NVARCHAR (300) NULL,
    [type_of_contact_method]                    NVARCHAR (300) NULL,
    [is_active]                                 BIT            NULL,
    [active_from]                               DATETIME2 (7)  NULL,
    [ref_type]                                  NVARCHAR (300) NULL,
    [ref_id]                                    NVARCHAR (36)  NULL,
    [extended_attributes_json__corrupt_record]  NVARCHAR (300) NULL,
    [extended_attributes_json_careOf]           NVARCHAR (300) NULL,
    [extended_attributes_json_district]         NVARCHAR (300) NULL,
    [extended_attributes_json_floor]            NVARCHAR (300) NULL,
    [extended_attributes_json_municipalityCode] NVARCHAR (300) NULL,
    [extended_attributes_json_namId]            NVARCHAR (36)  NULL,
    [extended_attributes_json_streetCode]       NVARCHAR (300) NULL,
    [extended_attributes_json_suite]            NVARCHAR (300) NULL,
    [contact_hour]                              NVARCHAR (300) NULL,
    [changed_by_json_userId]                    NVARCHAR (36)  NULL,
    [start_date_time]                           NVARCHAR (300) NULL,
    [end_date_time]                             NVARCHAR (300) NULL,
    [preferred_contact]                         BIT            NULL,
    [preferred_notification]                    BIT            NULL,
    [billing_data_json__corrupt_record]         NVARCHAR (300) NULL,
    [billing_data_json_addressFormat]           NVARCHAR (300) NULL,
    [social_network_id]                         NVARCHAR (36)  NULL,
    [is_deleted]                                BIT            NULL,
    [last_modified_ts]                          DATETIME2 (7)  NULL,
    [active_to]                                 NVARCHAR (300) NULL,
    [version]                                   INT            NULL,
    [is_current]                                BIT            NULL,
    [changed_by_json_userName]                  NVARCHAR (300) NULL,
    [NUUDL_ValidFrom]                           DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                             DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]                           BIT            NULL,
    [NUUDL_ID]                                  BIGINT         NOT NULL,
    [NUUDL_CuratedBatchID]                      BIGINT         NULL,
    [DWIsCurrent]                               BIT            NULL,
    [DWValidFromDate]                           DATETIME2 (7)  NOT NULL,
    [DWValidToDate]                             DATETIME2 (7)  NULL,
    [DWCreatedDate]                             DATETIME2 (7)  NULL,
    [DWModifiedDate]                            DATETIME2 (7)  NULL,
    [DWIsDeletedInSource]                       BIT            NULL,
    [DWDeletedInSourceDate]                     DATETIME2 (7)  NULL
);


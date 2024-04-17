CREATE TABLE [sourceNuudlNetCracker].[orgchartteammember] (
    [id]                                                   NVARCHAR (36)  NULL,
    [idm_user_id]                                          NVARCHAR (36)  NULL,
    [external_id]                                          NVARCHAR (36)  NULL,
    [name]                                                 NVARCHAR (300) NULL,
    [first_name]                                           NVARCHAR (300) NULL,
    [last_name]                                            NVARCHAR (300) NULL,
    [start_date]                                           DATETIME2 (7)  NULL,
    [end_date]                                             DATETIME2 (7)  NULL,
    [skill]                                                NVARCHAR (300) NULL,
    [position]                                             NVARCHAR (300) NULL,
    [geographic_site]                                      NVARCHAR (300) NULL,
    [is_deleted]                                           BIT            NULL,
    [last_modified_ts]                                     DATETIME2 (7)  NULL,
    [is_current]                                           BIT            NULL,
    [contact_medium_json_id]                               NVARCHAR (36)  NULL,
    [contact_medium_json_mediumType]                       NVARCHAR (300) NULL,
    [contact_medium_json_notDeactivated]                   BIT            NULL,
    [contact_medium_json_potentiallyActive]                BIT            NULL,
    [contact_medium_json_preferred]                        BIT            NULL,
    [contact_medium_json_preferredNotification]            BIT            NULL,
    [distribution_channel_json__corrupt_record]            NVARCHAR (300) NULL,
    [distribution_channel_json_default]                    NVARCHAR (300) NULL,
    [distribution_channel_json_id]                         NVARCHAR (36)  NULL,
    [distribution_channel_json_isDefaultOrFalse]           BIT            NULL,
    [distribution_channel_json_name]                       NVARCHAR (300) NULL,
    [idm_roles_json__corrupt_record]                       NVARCHAR (300) NULL,
    [contact_medium_json_characteristic_json_emailAddress] NVARCHAR (300) NULL,
    [contact_medium_json_validFor_json_endDateTime]        NVARCHAR (300) NULL,
    [contact_medium_json_validFor_json_startDateTime]      NVARCHAR (300) NULL,
    [NUUDL_ValidFrom]                                      DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                                        DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]                                      BIT            NULL,
    [NUUDL_ID]                                             BIGINT         NOT NULL,
    [NUUDL_StandardizedProcessedTimestamp]                 DATETIME2 (7)  NULL,
    [NUUDL_CuratedBatchID]                                 INT            NULL,
    [NUUDL_CuratedProcessedTimestamp]                      NVARCHAR (300) NULL,
    [NUUDL_CuratedSourceFilename]                          NVARCHAR (300) NULL,
    [DWCreatedDate]                                        DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_orgchartteammember] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_orgchartteammember]
    ON [sourceNuudlNetCracker].[orgchartteammember];


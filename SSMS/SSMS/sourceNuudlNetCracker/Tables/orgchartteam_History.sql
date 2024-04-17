CREATE TABLE [sourceNuudlNetCracker].[orgchartteam_History] (
    [id]                                                   NVARCHAR (36)  NULL,
    [idm_team_id]                                          NVARCHAR (36)  NULL,
    [external_id]                                          NVARCHAR (36)  NULL,
    [name]                                                 NVARCHAR (300) NULL,
    [start_date]                                           DATETIME2 (7)  NULL,
    [end_date]                                             DATETIME2 (7)  NULL,
    [type]                                                 NVARCHAR (300) NULL,
    [territory]                                            NVARCHAR (300) NULL,
    [business_calendar]                                    NVARCHAR (300) NULL,
    [is_deleted]                                           BIT            NULL,
    [last_modified_ts]                                     DATETIME2 (7)  NULL,
    [is_current]                                           BIT            NULL,
    [contact_medium_json__corrupt_record]                  NVARCHAR (300) NULL,
    [contact_medium_json_id]                               NVARCHAR (36)  NULL,
    [contact_medium_json_mediumType]                       NVARCHAR (300) NULL,
    [contact_medium_json_notDeactivated]                   BIT            NULL,
    [contact_medium_json_potentiallyActive]                BIT            NULL,
    [contact_medium_json_preferred]                        BIT            NULL,
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
    [DWIsCurrent]                                          BIT            NULL,
    [DWValidFromDate]                                      DATETIME2 (7)  NOT NULL,
    [DWValidToDate]                                        DATETIME2 (7)  NULL,
    [DWCreatedDate]                                        DATETIME2 (7)  NULL,
    [DWModifiedDate]                                       DATETIME2 (7)  NULL,
    [DWIsDeletedInSource]                                  BIT            NULL,
    [DWDeletedInSourceDate]                                DATETIME2 (7)  NULL,
    CONSTRAINT [PK_orgchartteam_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_orgchartteam_History]
    ON [sourceNuudlNetCracker].[orgchartteam_History];


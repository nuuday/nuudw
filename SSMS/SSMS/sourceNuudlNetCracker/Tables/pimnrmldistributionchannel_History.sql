CREATE TABLE [sourceNuudlNetCracker].[pimnrmldistributionchannel_History] (
    [localized_name_json_dan]                        NVARCHAR (300) NULL,
    [id]                                             NVARCHAR (36)  NULL,
    [name]                                           NVARCHAR (300) NULL,
    [extended_parameters_json_insurancePolicyPrefix] NVARCHAR (300) NULL,
    [extended_parameters_json_storeAddress]          NVARCHAR (300) NULL,
    [external_id]                                    NVARCHAR (36)  NULL,
    [extended_parameters_json__corrupt_record]       NVARCHAR (300) NULL,
    [extended_parameters_json_channelType]           NVARCHAR (300) NULL,
    [extended_parameters_json_storeID]               NVARCHAR (36)  NULL,
    [extended_parameters_json_storeName]             NVARCHAR (300) NULL,
    [cdc_revision_id]                                NVARCHAR (36)  NULL,
    [NUUDL_ValidFrom]                                DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                                  DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]                                BIT            NULL,
    [NUUDL_ID]                                       BIGINT         NOT NULL,
    [NUUDL_CuratedBatchID]                           BIGINT         NULL,
    [DWIsCurrent]                                    BIT            NULL,
    [DWValidFromDate]                                DATETIME2 (7)  NOT NULL,
    [DWValidToDate]                                  DATETIME2 (7)  NULL,
    [DWCreatedDate]                                  DATETIME2 (7)  NULL,
    [DWModifiedDate]                                 DATETIME2 (7)  NULL,
    [DWIsDeletedInSource]                            BIT            NULL,
    [DWDeletedInSourceDate]                          DATETIME2 (7)  NULL,
    CONSTRAINT [PK_pimnrmldistributionchannel_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_pimnrmldistributionchannel_History]
    ON [sourceNuudlNetCracker].[pimnrmldistributionchannel_History];


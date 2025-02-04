CREATE TABLE [sourceNuudlDawn].[esonrmlserviceinstances_History] (
    [_corrupt_record]                             NVARCHAR (4000) NULL,
    [activated_when]                              DATETIME2 (7)   NULL,
    [complex_service_data]                        NVARCHAR (MAX)  NULL,
    [created_date]                                DATETIME2 (7)   NULL,
    [customer_account_id]                         NVARCHAR (50)   NULL,
    [description]                                 NVARCHAR (MAX)  NULL,
    [domain]                                      NVARCHAR (4000) NULL,
    [id]                                          NVARCHAR (50)   NULL,
    [is_test_service]                             BIT             NULL,
    [last_modified_date]                          DATETIME2 (7)   NULL,
    [service_model_name]                          NVARCHAR (4000) NULL,
    [service_model_service_specification_id]      NVARCHAR (50)   NULL,
    [service_model_service_specification_name]    NVARCHAR (4000) NULL,
    [service_model_service_specification_version] NVARCHAR (4000) NULL,
    [service_model_state]                         NVARCHAR (4000) NULL,
    [service_type]                                NVARCHAR (4000) NULL,
    [ts_ms]                                       BIGINT          NULL,
    [lsn]                                         BIGINT          NULL,
    [op]                                          NVARCHAR (4000) NULL,
    [NUUDL_IsCurrent]                             BIT             NULL,
    [NUUDL_ValidFrom]                             DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]                               DATETIME2 (7)   NULL,
    [NUUDL_CuratedBatchID]                        INT             NULL,
    [NUUDL_CuratedProcessedTimestamp]             NVARCHAR (4000) NULL,
    [NUUDL_IsDeleted]                             BIT             NULL,
    [NUUDL_DeleteType]                            NVARCHAR (4000) NULL,
    [NUUDL_IsLatest]                              BIT             NULL,
    [NUUDL_ID]                                    BIGINT          NOT NULL,
    [DWIsCurrent]                                 BIT             NULL,
    [DWValidFromDate]                             DATETIME2 (7)   NOT NULL,
    [DWValidToDate]                               DATETIME2 (7)   NULL,
    [DWCreatedDate]                               DATETIME2 (7)   NULL,
    [DWModifiedDate]                              DATETIME2 (7)   NULL,
    [DWIsDeletedInSource]                         BIT             NULL,
    [DWDeletedInSourceDate]                       DATETIME2 (7)   NULL,
    CONSTRAINT [PK_esonrmlserviceinstances_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_esonrmlserviceinstances_History]
    ON [sourceNuudlDawn].[esonrmlserviceinstances_History];


CREATE TABLE [sourceNuudlDawn].[qssnrmlquoteitem_History] (
    [account_id]                      NVARCHAR (50)   NULL,
    [action]                          NVARCHAR (4000) NULL,
    [active_from]                     DATETIME2 (7)   NULL,
    [active_to]                       DATETIME2 (7)   NULL,
    [amount]                          DECIMAL (10)    NULL,
    [approval_level]                  DECIMAL (10)    NULL,
    [availability_check_result]       NVARCHAR (4000) NULL,
    [business_action]                 NVARCHAR (4000) NULL,
    [business_group_id]               NVARCHAR (50)   NULL,
    [business_group_name]             NVARCHAR (4000) NULL,
    [contracted_date]                 DATETIME2 (7)   NULL,
    [creation_time]                   DATETIME2 (7)   NULL,
    [disconnection_reason]            NVARCHAR (4000) NULL,
    [distribution_channel_id]         NVARCHAR (50)   NULL,
    [extended_parameters]             NVARCHAR (MAX)  NULL,
    [geo_site_id]                     NVARCHAR (50)   NULL,
    [id]                              NVARCHAR (50)   NULL,
    [market_id]                       NVARCHAR (50)   NULL,
    [marketing_bundle_id]             NVARCHAR (50)   NULL,
    [number_of_installments]          DECIMAL (10)    NULL,
    [parent_quote_item_id]            NVARCHAR (50)   NULL,
    [planned_disconnection_date]      DATETIME2 (7)   NULL,
    [product_instance_id]             NVARCHAR (50)   NULL,
    [product_offering_id]             NVARCHAR (50)   NULL,
    [product_specification_id]        NVARCHAR (50)   NULL,
    [product_specification_version]   NVARCHAR (4000) NULL,
    [quantity]                        BIGINT          NULL,
    [quote_id]                        NVARCHAR (50)   NULL,
    [quote_version]                   NVARCHAR (4000) NULL,
    [root_quote_item_id]              NVARCHAR (50)   NULL,
    [state]                           NVARCHAR (4000) NULL,
    [delivery_item_id]                NVARCHAR (50)   NULL,
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
    [NUUDL_IsLatest]                  BIT             NULL,
    [NUUDL_ID]                        BIGINT          NOT NULL,
    [DWIsCurrent]                     BIT             NULL,
    [DWValidFromDate]                 DATETIME2 (7)   NOT NULL,
    [DWValidToDate]                   DATETIME2 (7)   NULL,
    [DWCreatedDate]                   DATETIME2 (7)   NULL,
    [DWModifiedDate]                  DATETIME2 (7)   NULL,
    [DWIsDeletedInSource]             BIT             NULL,
    [DWDeletedInSourceDate]           DATETIME2 (7)   NULL,
    CONSTRAINT [PK_qssnrmlquoteitem_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);








GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_qssnrmlquoteitem_History]
    ON [sourceNuudlDawn].[qssnrmlquoteitem_History];






GO



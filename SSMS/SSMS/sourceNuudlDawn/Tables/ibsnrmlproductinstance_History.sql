CREATE TABLE [sourceNuudlDawn].[ibsnrmlproductinstance_History] (
    [account_ref_id]                   NVARCHAR (50)  NULL,
    [business_group]                   NVARCHAR (500) NULL,
    [contracted_date]                  DATETIME2 (7)  NULL,
    [customer_id]                      NVARCHAR (50)  NULL,
    [description]                      NVARCHAR (MAX) NULL,
    [disconnection_reason]             NVARCHAR (500) NULL,
    [disconnection_reason_description] NVARCHAR (500) NULL,
    [effective_date]                   DATETIME2 (7)  NULL,
    [eligibility_param_id]             NVARCHAR (50)  NULL,
    [expiration_date]                  DATETIME2 (7)  NULL,
    [extended_attributes]              NVARCHAR (MAX) NULL,
    [extended_eligibility]             NVARCHAR (500) NULL,
    [external_id]                      NVARCHAR (50)  NULL,
    [id]                               NVARCHAR (50)  NULL,
    [idempotency_key]                  NVARCHAR (500) NULL,
    [last_modified]                    DATETIME2 (7)  NULL,
    [name]                             NVARCHAR (500) NULL,
    [number_of_installments]           INT            NULL,
    [offering_id]                      NVARCHAR (50)  NULL,
    [op]                               NVARCHAR (500) NULL,
    [override_mode]                    NVARCHAR (500) NULL,
    [parent_id]                        NVARCHAR (50)  NULL,
    [place_ref_id]                     NVARCHAR (50)  NULL,
    [product_order_id]                 NVARCHAR (50)  NULL,
    [product_specification_id]         NVARCHAR (50)  NULL,
    [product_specification_version]    DECIMAL (10)   NULL,
    [quantity]                         BIGINT         NULL,
    [quote_id]                         NVARCHAR (50)  NULL,
    [root_id]                          NVARCHAR (50)  NULL,
    [source_quote_item_id]             NVARCHAR (50)  NULL,
    [start_date]                       DATETIME2 (7)  NULL,
    [state]                            NVARCHAR (500) NULL,
    [suspended]                        BIT            NULL,
    [termination_date]                 DATETIME2 (7)  NULL,
    [ts_ms]                            BIGINT         NULL,
    [type]                             NVARCHAR (500) NULL,
    [version]                          BIGINT         NULL,
    [NUUDL_CuratedBatchID]             INT            NULL,
    [NUUDL_CuratedProcessedTimestamp]  NVARCHAR (500) NULL,
    [NUUDL_IsCurrent]                  BIT            NULL,
    [NUUDL_ValidFrom]                  DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                    DATETIME2 (7)  NULL,
    [NUUDL_ID]                         BIGINT         NOT NULL,
    [DWIsCurrent]                      BIT            NULL,
    [DWValidFromDate]                  DATETIME2 (7)  NOT NULL,
    [DWValidToDate]                    DATETIME2 (7)  NULL,
    [DWCreatedDate]                    DATETIME2 (7)  NULL,
    [DWModifiedDate]                   DATETIME2 (7)  NULL,
    [DWIsDeletedInSource]              BIT            NULL,
    [DWDeletedInSourceDate]            DATETIME2 (7)  NULL,
    CONSTRAINT [PK_ibsnrmlproductinstance_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);




GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ibsnrmlproductinstance_History]
    ON [sourceNuudlDawn].[ibsnrmlproductinstance_History];


GO
CREATE NONCLUSTERED INDEX [NCIX_ibsnrmlproductinstance_History__quote_id_NUUDL_IsCurrent_DWIsCurrent]
    ON [sourceNuudlDawn].[ibsnrmlproductinstance_History]([quote_id] ASC, [NUUDL_IsCurrent] ASC, [DWIsCurrent] ASC)
    INCLUDE([id], [parent_id]);


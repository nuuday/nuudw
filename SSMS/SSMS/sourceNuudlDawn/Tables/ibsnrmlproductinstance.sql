CREATE TABLE [sourceNuudlDawn].[ibsnrmlproductinstance] (
    [account_ref_id]                   NVARCHAR (50)   NULL,
    [business_group]                   NVARCHAR (4000) NULL,
    [contracted_date]                  NVARCHAR (4000) NULL,
    [customer_id]                      NVARCHAR (50)   NULL,
    [description]                      NVARCHAR (MAX)  NULL,
    [disconnection_reason]             NVARCHAR (4000) NULL,
    [disconnection_reason_description] NVARCHAR (4000) NULL,
    [effective_date]                   DATETIME2 (7)   NULL,
    [eligibility_param_id]             NVARCHAR (50)   NULL,
    [expiration_date]                  NVARCHAR (4000) NULL,
    [extended_attributes]              NVARCHAR (MAX)  NULL,
    [extended_eligibility]             NVARCHAR (4000) NULL,
    [external_id]                      NVARCHAR (50)   NULL,
    [id]                               NVARCHAR (50)   NULL,
    [idempotency_key]                  NVARCHAR (4000) NULL,
    [last_modified]                    DATETIME2 (7)   NULL,
    [name]                             NVARCHAR (4000) NULL,
    [number_of_installments]           NVARCHAR (4000) NULL,
    [offering_id]                      NVARCHAR (50)   NULL,
    [override_mode]                    NVARCHAR (4000) NULL,
    [parent_id]                        NVARCHAR (50)   NULL,
    [place_ref_id]                     NVARCHAR (50)   NULL,
    [product_order_id]                 NVARCHAR (50)   NULL,
    [product_specification_id]         NVARCHAR (50)   NULL,
    [product_specification_version]    NVARCHAR (4000) NULL,
    [quantity]                         NVARCHAR (4000) NULL,
    [quote_id]                         NVARCHAR (50)   NULL,
    [root_id]                          NVARCHAR (50)   NULL,
    [source_quote_item_id]             NVARCHAR (50)   NULL,
    [start_date]                       DATETIME2 (7)   NULL,
    [state]                            NVARCHAR (4000) NULL,
    [suspended]                        NVARCHAR (4000) NULL,
    [termination_date]                 DATETIME2 (7)   NULL,
    [type]                             NVARCHAR (4000) NULL,
    [version]                          NVARCHAR (4000) NULL,
    [ts_ms]                            BIGINT          NULL,
    [lsn]                              BIGINT          NULL,
    [op]                               NVARCHAR (4000) NULL,
    [NUUDL_IsCurrent]                  BIT             NULL,
    [NUUDL_ValidFrom]                  DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]                    DATETIME2 (7)   NULL,
    [NUUDL_CuratedBatchID]             INT             NULL,
    [NUUDL_CuratedProcessedTimestamp]  NVARCHAR (4000) NULL,
    [NUUDL_IsDeleted]                  BIT             NULL,
    [NUUDL_DeleteType]                 NVARCHAR (4000) NULL,
    [NUUDL_ID]                         BIGINT          NOT NULL,
    [NUUDL_IsLatest]                   BIT             NULL,
    [DWCreatedDate]                    DATETIME2 (7)   DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_ibsnrmlproductinstance] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);






GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ibsnrmlproductinstance]
    ON [sourceNuudlDawn].[ibsnrmlproductinstance];






CREATE TABLE [sourceNuudlDawn].[ibsitemshistory] (
    [active_from]                               DATETIME2 (7)   NULL,
    [active_to]                                 DATETIME2 (7)   NULL,
    [id]                                        NVARCHAR (50)   NULL,
    [idempotency_key]                           NVARCHAR (4000) NULL,
    [is_snapshot]                               BIT             NULL,
    [item]                                      NVARCHAR (MAX)  NULL,
    [last_modified_ts]                          DATETIME2 (7)   NULL,
    [schema_version]                            NVARCHAR (4000) NULL,
    [is_deleted]                                BIT             NULL,
    [state]                                     NVARCHAR (4000) NULL,
    [is_current]                                BIT             NULL,
    [version]                                   BIGINT          NULL,
    [ts_ms]                                     BIGINT          NULL,
    [lsn]                                       BIGINT          NULL,
    [op]                                        NVARCHAR (4000) NULL,
    [item_accountRef]                           NVARCHAR (4000) NULL,
    [item_businessGroup_id]                     NVARCHAR (4000) NULL,
    [item_customerId]                           NVARCHAR (4000) NULL,
    [item_distributionChannelId]                NVARCHAR (4000) NULL,
    [item_expirationDate]                       NVARCHAR (4000) NULL,
    [item_extendedAttributes]                   NVARCHAR (4000) NULL,
    [item_name]                                 NVARCHAR (4000) NULL,
    [item_offeringId]                           NVARCHAR (4000) NULL,
    [item_offeringName]                         NVARCHAR (4000) NULL,
    [item_parentId]                             NVARCHAR (4000) NULL,
    [item_prices]                               NVARCHAR (4000) NULL,
    [item_productFamilyId]                      NVARCHAR (4000) NULL,
    [item_productFamilyName]                    NVARCHAR (4000) NULL,
    [item_productRelationship_productId]        NVARCHAR (4000) NULL,
    [item_productRelationship_relationshipType] NVARCHAR (4000) NULL,
    [item_productSpecificationRef]              NVARCHAR (4000) NULL,
    [item_quantity]                             NVARCHAR (4000) NULL,
    [item_quoteId]                              NVARCHAR (4000) NULL,
    [item_relatedPartyRef]                      NVARCHAR (4000) NULL,
    [item_rootId]                               NVARCHAR (4000) NULL,
    [item_type]                                 NVARCHAR (4000) NULL,
    [item_version]                              NVARCHAR (4000) NULL,
    [NUUDL_IsCurrent]                           BIT             NULL,
    [NUUDL_ValidFrom]                           DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]                             DATETIME2 (7)   NULL,
    [NUUDL_CuratedBatchID]                      INT             NULL,
    [NUUDL_CuratedProcessedTimestamp]           NVARCHAR (4000) NULL,
    [NUUDL_IsDeleted]                           BIT             NULL,
    [NUUDL_DeleteType]                          NVARCHAR (4000) NULL,
    [NUUDL_ID]                                  BIGINT          NOT NULL,
    [NUUDL_IsLatest]                            BIT             NULL,
    [DWCreatedDate]                             DATETIME2 (7)   DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_ibsitemshistory] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);








GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ibsitemshistory]
    ON [sourceNuudlDawn].[ibsitemshistory];








﻿CREATE TABLE [sourceNuudlDawn].[nrmcustproductdetails_History] (
    [account_num]                     NVARCHAR (4000) NULL,
    [budget_centre_seq]               BIGINT          NULL,
    [budget_payment_plan_id]          BIGINT          NULL,
    [community_group_id]              BIGINT          NULL,
    [community_group_owner_boo]       NVARCHAR (4000) NULL,
    [contract_seq]                    BIGINT          NULL,
    [cps_id]                          BIGINT          NULL,
    [cust_product_contact_seq]        BIGINT          NULL,
    [customer_ref]                    NVARCHAR (4000) NULL,
    [default_event_source]            NVARCHAR (4000) NULL,
    [domain_id]                       BIGINT          NULL,
    [end_dat]                         DATETIME2 (7)   NULL,
    [override_product_name]           NVARCHAR (4000) NULL,
    [product_label]                   NVARCHAR (4000) NULL,
    [product_seq]                     BIGINT          NULL,
    [start_dat]                       DATETIME2 (7)   NULL,
    [tax_exempt_ref]                  NVARCHAR (4000) NULL,
    [tax_exempt_txt]                  NVARCHAR (4000) NULL,
    [tax_inclusive_boo]               NVARCHAR (4000) NULL,
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
    [NUUDL_ID]                        BIGINT          NOT NULL,
    [NUUDL_IsLatest]                  BIT             NULL,
    [DWIsCurrent]                     BIT             NULL,
    [DWValidFromDate]                 DATETIME2 (7)   NOT NULL,
    [DWValidToDate]                   DATETIME2 (7)   NULL,
    [DWCreatedDate]                   DATETIME2 (7)   NULL,
    [DWModifiedDate]                  DATETIME2 (7)   NULL,
    [DWIsDeletedInSource]             BIT             NULL,
    [DWDeletedInSourceDate]           DATETIME2 (7)   NULL,
    CONSTRAINT [PK_nrmcustproductdetails_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);






GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_nrmcustproductdetails_History]
    ON [sourceNuudlDawn].[nrmcustproductdetails_History];






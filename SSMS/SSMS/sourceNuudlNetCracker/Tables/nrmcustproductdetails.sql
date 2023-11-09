CREATE TABLE [sourceNuudlNetCracker].[nrmcustproductdetails] (
    [customer_ref]              NVARCHAR (300) NULL,
    [product_seq]               INT            NULL,
    [start_dat]                 DATETIME2 (7)  NULL,
    [end_dat]                   DATETIME2 (7)  NULL,
    [account_num]               NVARCHAR (300) NULL,
    [budget_centre_seq]         INT            NULL,
    [product_label]             NVARCHAR (300) NULL,
    [cust_product_contact_seq]  INT            NULL,
    [contract_seq]              INT            NULL,
    [cps_id]                    INT            NULL,
    [tax_exempt_ref]            NVARCHAR (300) NULL,
    [tax_exempt_txt]            NVARCHAR (300) NULL,
    [default_event_source]      NVARCHAR (300) NULL,
    [domain_id]                 INT            NULL,
    [budget_payment_plan_id]    INT            NULL,
    [community_group_id]        INT            NULL,
    [community_group_owner_boo] NVARCHAR (300) NULL,
    [override_product_name]     NVARCHAR (300) NULL,
    [tax_inclusive_boo]         NVARCHAR (300) NULL,
    [is_current]                BIT            NULL,
    [NUUDL_ValidFrom]           DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]             DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]           BIT            NULL,
    [NUUDL_ID]                  BIGINT         NOT NULL,
    [NUUDL_CuratedBatchID]      BIGINT         NULL,
    [DWCreatedDate]             DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_nrmcustproductdetails] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_nrmcustproductdetails]
    ON [sourceNuudlNetCracker].[nrmcustproductdetails];


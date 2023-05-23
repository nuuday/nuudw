CREATE TABLE [sourceDataLakeNetcracker_interim].[custproductdetails] (
    [customer_ref]              NVARCHAR (500) NULL,
    [product_seq]               INT            NULL,
    [start_dat]                 NVARCHAR (500) NULL,
    [end_dat]                   NVARCHAR (500) NULL,
    [account_num]               NVARCHAR (500) NULL,
    [budget_centre_seq]         INT            NULL,
    [product_label]             NVARCHAR (500) NULL,
    [cust_product_contact_seq]  INT            NULL,
    [contract_seq]              INT            NULL,
    [cps_id]                    INT            NULL,
    [tax_exempt_ref]            NVARCHAR (500) NULL,
    [tax_exempt_txt]            NVARCHAR (500) NULL,
    [default_event_source]      NVARCHAR (500) NULL,
    [domain_id]                 INT            NULL,
    [budget_payment_plan_id]    INT            NULL,
    [community_group_id]        INT            NULL,
    [community_group_owner_boo] NVARCHAR (500) NULL,
    [override_product_name]     NVARCHAR (500) NULL,
    [tax_inclusive_boo]         NVARCHAR (500) NULL,
    [DWCreatedDate]             DATETIME       DEFAULT (getdate()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'TruncateBeforeDeploy', @value = N'True', @level0type = N'SCHEMA', @level0name = N'sourceDataLakeNetcracker_interim', @level1type = N'TABLE', @level1name = N'custproductdetails';


CREATE TABLE [sourceDataLakeNetcracker_interim].[adjustment] (
    [account_num]                    NVARCHAR (500) NULL,
    [adjustment_seq]                 INT            NULL,
    [adjustment_dat]                 NVARCHAR (500) NULL,
    [adjustment_type_id]             INT            NULL,
    [adjustment_txt]                 NVARCHAR (500) NULL,
    [adjustment_net_mny]             BIGINT         NULL,
    [created_dtm]                    NVARCHAR (500) NULL,
    [dispute_seq]                    INT            NULL,
    [adjustment_status]              INT            NULL,
    [budget_centre_seq]              INT            NULL,
    [bill_seq]                       INT            NULL,
    [cps_id]                         INT            NULL,
    [geneva_user_ora]                NVARCHAR (500) NULL,
    [approved_dtm]                   NVARCHAR (500) NULL,
    [outcome_desc]                   NVARCHAR (500) NULL,
    [receivable_class_id]            INT            NULL,
    [adjustment_debt_mny]            BIGINT         NULL,
    [adjustment_tax_mny]             BIGINT         NULL,
    [linked_writeoff_payment_seq]    INT            NULL,
    [billtimecharge_created_adj_boo] NVARCHAR (500) NULL,
    [group_name]                     NVARCHAR (500) NULL,
    [revenue_code_id]                INT            NULL,
    [DWCreatedDate]                  DATETIME       DEFAULT (getdate()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'TruncateBeforeDeploy', @value = N'True', @level0type = N'SCHEMA', @level0name = N'sourceDataLakeNetcracker_interim', @level1type = N'TABLE', @level1name = N'adjustment';


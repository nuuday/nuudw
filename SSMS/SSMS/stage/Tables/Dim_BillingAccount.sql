CREATE TABLE [stage].[Dim_BillingAccount] (
    [BillingAccountKey] NVARCHAR (10) NULL,
    [DWCreatedDate]     DATETIME2 (0) DEFAULT (sysdatetime()) NOT NULL
);




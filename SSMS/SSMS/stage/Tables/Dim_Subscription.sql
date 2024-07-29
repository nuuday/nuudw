CREATE TABLE [stage].[Dim_Subscription] (
    [SubscriptionKey]           NVARCHAR (36)  NULL,
    [FamilyBundle]              NVARCHAR (100) NULL,
    [BundleType]                NVARCHAR (100) NULL,
    [SubscriptionValidFromDate] DATETIME2 (7)  NULL,
    [SubscriptionValidToDate]   DATETIME2 (7)  NULL,
    [SubscriptionIsCurrent]     BIT            NULL,
    [DWCreatedDate]             DATETIME2 (0)  DEFAULT (sysdatetime()) NOT NULL
);






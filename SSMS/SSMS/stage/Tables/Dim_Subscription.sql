CREATE TABLE [stage].[Dim_Subscription] (
    [SubscriptionKey] NVARCHAR (36) NULL,
    [DWCreatedDate]   DATETIME2 (0) DEFAULT (sysdatetime()) NOT NULL
);




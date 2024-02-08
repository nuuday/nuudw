CREATE TABLE [dim].[BillingAccount] (
    [BillingAccountID]  INT           IDENTITY (1, 1) NOT NULL,
    [BillingAccountKey] NVARCHAR (10) NULL,
    [DWIsCurrent]       BIT           NOT NULL,
    [DWValidFromDate]   DATETIME2 (0) NOT NULL,
    [DWValidToDate]     DATETIME2 (0) NOT NULL,
    [DWCreatedDate]     DATETIME2 (0) NOT NULL,
    [DWModifiedDate]    DATETIME2 (0) NOT NULL,
    [DWIsDeleted]       BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([BillingAccountID] ASC),
    CONSTRAINT [NCI_BillingAccount] UNIQUE NONCLUSTERED ([BillingAccountKey] ASC, [DWValidFromDate] ASC)
);


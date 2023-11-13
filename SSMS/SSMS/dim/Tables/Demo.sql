CREATE TABLE [dim].[Demo] (
    [DemoID]          INT            IDENTITY (1, 1) NOT NULL,
    [Demokey]         NVARCHAR (12)  NULL,
    [name]            NVARCHAR (250) NULL,
    [DWIsCurrent]     BIT            NOT NULL,
    [DWValidFromDate] DATETIME2 (0)  NOT NULL,
    [DWValidToDate]   DATETIME2 (0)  NOT NULL,
    [DWCreatedDate]   DATETIME2 (0)  NOT NULL,
    [DWModifiedDate]  DATETIME2 (0)  NOT NULL,
    [DWIsDeleted]     BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([DemoID] ASC),
    CONSTRAINT [NCI_Demo] UNIQUE NONCLUSTERED ([Demokey] ASC, [DWValidFromDate] ASC)
);


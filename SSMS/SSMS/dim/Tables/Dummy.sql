CREATE TABLE [dim].[Dummy] (
    [DummyID]         INT            IDENTITY (1, 1) NOT NULL,
    [DummyKey]        NVARCHAR (300) NULL,
    [SomeAttribute]   NVARCHAR (50)  NULL,
    [DWIsCurrent]     BIT            NOT NULL,
    [DWValidFromDate] DATETIME2 (0)  NOT NULL,
    [DWValidToDate]   DATETIME2 (0)  NOT NULL,
    [DWCreatedDate]   DATETIME2 (0)  NOT NULL,
    [DWModifiedDate]  DATETIME2 (0)  NOT NULL,
    [DWIsDeleted]     BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([DummyID] ASC),
    CONSTRAINT [NCI_Dummy] UNIQUE NONCLUSTERED ([DummyKey] ASC, [DWValidFromDate] ASC)
);


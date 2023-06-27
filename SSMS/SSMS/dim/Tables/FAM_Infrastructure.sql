CREATE TABLE [dim].[FAM_Infrastructure] (
    [FAM_InfrastructureID]  INT            IDENTITY (1, 1) NOT NULL,
    [FAM_InfrastructureKey] NVARCHAR (200) NULL,
    [InfrastructureName]    NVARCHAR (200) NULL,
    [DWIsCurrent]           BIT            NOT NULL,
    [DWValidFromDate]       DATETIME2 (0)  NOT NULL,
    [DWValidToDate]         DATETIME2 (0)  NOT NULL,
    [DWCreatedDate]         DATETIME2 (0)  NOT NULL,
    [DWModifiedDate]        DATETIME2 (0)  NOT NULL,
    [DWIsDeleted]           BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([FAM_InfrastructureID] ASC),
    CONSTRAINT [NCI_FAM_Infrastructure] UNIQUE NONCLUSTERED ([FAM_InfrastructureKey] ASC, [DWValidFromDate] ASC)
);


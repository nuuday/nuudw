CREATE TABLE [dim].[FAM_ChipperStatus] (
    [FAM_ChipperStatusID]  INT            IDENTITY (1, 1) NOT NULL,
    [FAM_ChipperStatusKey] NVARCHAR (500) NULL,
    [ChipperStatusName]    NVARCHAR (500) NULL,
    [DWIsCurrent]          BIT            NOT NULL,
    [DWValidFromDate]      DATETIME2 (0)  NOT NULL,
    [DWValidToDate]        DATETIME2 (0)  NOT NULL,
    [DWCreatedDate]        DATETIME2 (0)  NOT NULL,
    [DWModifiedDate]       DATETIME2 (0)  NOT NULL,
    [DWIsDeleted]          BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([FAM_ChipperStatusID] ASC),
    CONSTRAINT [NCI_FAM_ChipperStatus] UNIQUE NONCLUSTERED ([FAM_ChipperStatusKey] ASC, [DWValidFromDate] ASC)
);


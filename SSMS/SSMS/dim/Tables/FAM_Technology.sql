CREATE TABLE [dim].[FAM_Technology] (
    [FAM_TechnologyID]  INT           IDENTITY (1, 1) NOT NULL,
    [FAM_TechnologyKey] NVARCHAR (15) NULL,
    [TechnologyName]    NVARCHAR (15) NULL,
    [DWIsCurrent]       BIT           NOT NULL,
    [DWValidFromDate]   DATETIME2 (0) NOT NULL,
    [DWValidToDate]     DATETIME2 (0) NOT NULL,
    [DWCreatedDate]     DATETIME2 (0) NOT NULL,
    [DWModifiedDate]    DATETIME2 (0) NOT NULL,
    [DWIsDeleted]       BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([FAM_TechnologyID] ASC),
    CONSTRAINT [NCI_FAM_Technology] UNIQUE NONCLUSTERED ([FAM_TechnologyKey] ASC, [DWValidFromDate] ASC)
);


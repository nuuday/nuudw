CREATE TABLE [dim].[FAM_OpenIncidentsGroup] (
    [FAM_OpenIncidentsGroupID]  INT           IDENTITY (1, 1) NOT NULL,
    [FAM_OpenIncidentsGroupKey] VARCHAR (1)   NULL,
    [OpenIncidentsGroup]        VARCHAR (15)  NULL,
    [DWIsCurrent]               BIT           NOT NULL,
    [DWValidFromDate]           DATETIME2 (0) NOT NULL,
    [DWValidToDate]             DATETIME2 (0) NOT NULL,
    [DWCreatedDate]             DATETIME2 (0) NOT NULL,
    [DWModifiedDate]            DATETIME2 (0) NOT NULL,
    [DWIsDeleted]               BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([FAM_OpenIncidentsGroupID] ASC),
    CONSTRAINT [NCI_FAM_OpenIncidentsGroup] UNIQUE NONCLUSTERED ([FAM_OpenIncidentsGroupKey] ASC, [DWValidFromDate] ASC)
);


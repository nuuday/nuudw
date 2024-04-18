CREATE TABLE [dim].[Employee] (
    [EmployeeID]           INT           IDENTITY (1, 1) NOT NULL,
    [EmployeeKey]          NVARCHAR (10) NULL,
    [EmployeeName]         NVARCHAR (50) NULL,
    [EmployeeEmail]        NVARCHAR (50) NULL,
    [OrganizationalLevel1] NVARCHAR (1)  NULL,
    [OrganizationalLevel2] NVARCHAR (2)  NULL,
    [OrganizationalLevel3] NVARCHAR (3)  NULL,
    [DWIsCurrent]          BIT           NOT NULL,
    [DWValidFromDate]      DATETIME2 (0) NOT NULL,
    [DWValidToDate]        DATETIME2 (0) NOT NULL,
    [DWCreatedDate]        DATETIME2 (0) NOT NULL,
    [DWModifiedDate]       DATETIME2 (0) NOT NULL,
    [DWIsDeleted]          BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([EmployeeID] ASC),
    CONSTRAINT [NCI_Employee] UNIQUE NONCLUSTERED ([EmployeeKey] ASC, [DWValidFromDate] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Employee', @level2type = N'COLUMN', @level2name = N'OrganizationalLevel3';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Employee', @level2type = N'COLUMN', @level2name = N'OrganizationalLevel2';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Employee', @level2type = N'COLUMN', @level2name = N'OrganizationalLevel1';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Employee', @level2type = N'COLUMN', @level2name = N'EmployeeEmail';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Employee', @level2type = N'COLUMN', @level2name = N'EmployeeName';


GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Employee', @level2type = N'COLUMN', @level2name = N'EmployeeKey';


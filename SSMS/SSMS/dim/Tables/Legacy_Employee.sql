CREATE TABLE [dim].[Legacy_Employee] (
    [Legacy_EmployeeID]                  INT           IDENTITY (1, 1) NOT NULL,
    [Legacy_EmployeeKey]                 INT           NULL,
    [EmployeeFirstName]                  NVARCHAR (30) NULL,
    [EmployeeLastName]                   NVARCHAR (30) NULL,
    [EmployeeName]                       NVARCHAR (92) NULL,
    [EmployeeUserCode]                   NVARCHAR (30) NULL,
    [TerminationDate]                    DATETIME      NULL,
    [EmployeeDepartmentDescriptionShort] NVARCHAR (10) NULL,
    [EmployeeOrganizationCode]           NVARCHAR (3)  NULL,
    [Legacy_EmployeeIsCurrent]           BIT           NULL,
    [Legacy_EmployeeValidFromDate]       DATETIME      NULL,
    [Legacy_EmployeeValidToDate]         DATETIME      NULL,
    [DWIsCurrent]                        BIT           NOT NULL,
    [DWValidFromDate]                    DATETIME2 (0) NOT NULL,
    [DWValidToDate]                      DATETIME2 (0) NOT NULL,
    [DWCreatedDate]                      DATETIME2 (0) NOT NULL,
    [DWModifiedDate]                     DATETIME2 (0) NOT NULL,
    [DWIsDeleted]                        BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([Legacy_EmployeeID] ASC),
    CONSTRAINT [NCI_Legacy_Employee] UNIQUE NONCLUSTERED ([Legacy_EmployeeKey] ASC, [Legacy_EmployeeValidFromDate] ASC)
);




GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'HistoryType', @value = N'Type2', @level0type = N'SCHEMA', @level0name = N'dim', @level1type = N'TABLE', @level1name = N'Legacy_Employee', @level2type = N'COLUMN', @level2name = N'Legacy_EmployeeKey';


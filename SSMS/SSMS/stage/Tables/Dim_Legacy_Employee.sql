CREATE TABLE [stage].[Dim_Legacy_Employee] (
    [Legacy_EmployeeKey]                 INT           NOT NULL,
    [EmployeeFirstName]                  NVARCHAR (30) NULL,
    [EmployeeLastName]                   NVARCHAR (30) NULL,
    [EmployeeName]                       NVARCHAR (92) NULL,
    [EmployeeUserCode]                   NVARCHAR (30) NULL,
    [TerminationDate]                    DATETIME      NULL,
    [EmployeeDepartmentDescriptionShort] NVARCHAR (10) NULL,
    [EmployeeOrganizationCode]           NVARCHAR (3)  NOT NULL,
    [Legacy_EmployeeIsCurrent]           BIT           NULL,
    [Legacy_EmployeeValidFromDate]       DATETIME      NOT NULL,
    [Legacy_EmployeeValidToDate]         DATETIME      NULL,
    [DWCreatedDate]                      DATETIME      NOT NULL
);


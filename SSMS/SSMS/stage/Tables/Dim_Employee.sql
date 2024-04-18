CREATE TABLE [stage].[Dim_Employee] (
    [EmployeeKey]          NVARCHAR (10) NULL,
    [EmployeeName]         NVARCHAR (50) NULL,
    [EmployeeEmail]        NVARCHAR (50) NULL,
    [OrganizationalLevel1] NVARCHAR (1)  NULL,
    [OrganizationalLevel2] NVARCHAR (2)  NULL,
    [OrganizationalLevel3] NVARCHAR (3)  NULL,
    [DWCreatedDate]        DATETIME2 (0) DEFAULT (sysdatetime()) NULL
);




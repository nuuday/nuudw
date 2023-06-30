CREATE TABLE [bridge].[UserAccess] (
    [Legacy_EmployeeID] INT            DEFAULT ((-1)) NOT NULL,
    [TopManager]        INT            NULL,
    [EmployeeName]      NVARCHAR (255) NULL,
    [UserName]          NVARCHAR (255) NULL,
    [DWCreatedDate]     DATETIME2 (0)  NOT NULL,
    [DWModifiedDate]    DATETIME2 (0)  NOT NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_UserAccess]
    ON [bridge].[UserAccess];

